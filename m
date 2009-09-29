From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [RFC PATCH 0/9] sunrpc: teach the SUNRPC
	layer how to speak SMB
Date: Tue, 29 Sep 2009 07:30:31 -0400
Message-ID: <20090929073031.097085ac@tlielax.poochiereds.net>
References: <mailman.1290.1254136357.2670.linux-cifs-client@lists.samba.org>
	<4AC0CB04.9070502@us.ibm.com>
	<20090928115427.4103826e@tlielax.poochiereds.net>
	<4AC10317.5090403@us.ibm.com>
	<20090928153737.65c1ba3e@tlielax.poochiereds.net>
	<4AC12D53.6060202@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, linux-cifs-client@lists.samba.org
To: "Steve French (smfltc)" <smfltc@us.ibm.com>
Return-path: <linux-cifs-client-bounces@lists.samba.org>
In-Reply-To: <4AC12D53.6060202@us.ibm.com>
List-Unsubscribe: <https://lists.samba.org/mailman/options/linux-cifs-client>,
	<mailto:linux-cifs-client-request@lists.samba.org?subject=unsubscribe>
List-Archive: <http://lists.samba.org/pipermail/linux-cifs-client>
List-Post: <mailto:linux-cifs-client@lists.samba.org>
List-Help: <mailto:linux-cifs-client-request@lists.samba.org?subject=help>
List-Subscribe: <https://lists.samba.org/mailman/listinfo/linux-cifs-client>,
	<mailto:linux-cifs-client-request@lists.samba.org?subject=subscribe>
Sender: linux-cifs-client-bounces@lists.samba.org
Errors-To: linux-cifs-client-bounces@lists.samba.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 28 Sep 2009 16:40:35 -0500
"Steve French (smfltc)" <smfltc@us.ibm.com> wrote:

> Jeff Layton wrote:
> > On Mon, 28 Sep 2009 13:40:23 -0500
> > "Steve French (smfltc)" <smfltc@us.ibm.com> wrote:
> >
> >   
> >> Jeff Layton wrote:
> >>     
> >>> On Mon, 28 Sep 2009 09:41:08 -0500
> >>> "Steve French (smfltc)" <smfltc@us.ibm.com> wrote:
> >>>
> >>>     
> >>>       
> >>>   
> >>>       
> >> I don't think it changes the number of tasks sleeping.   For sync 
> >> operations it doesn't
> >> change how many tasks that are sleeping.   For async operations, you no 
> >> longer have a
> >> task sleeping in cifs_writepages or cifs_readpages, but do have the 
> >> ability to dispatch
> >> a decode routine when the SMB Write or Read response is returned (may or
> >> may not have a pool to do this).   Seems like about the same number of 
> >> task (possibly
> >> less).   Moving to all asynchronous operations under open, unlink, close 
> >> doesn't reduce
> >> the number of sleeping tasks (it may increase it or stay the same).
> >>     
> >
> > I think it does. Take the example of asynchronous writepages requests.
> > You want to send a bunch of write calls in quick succession and then
> > process the replies as they come in. If you rely on a SendReceive-type
> > interface, you have no choice but to spawn a separate slow_work task
> > for each call on the wire. No guarantee they'll run in parallel though
> > (depends on the rules for spawning new kslowd threads).
> >
> > Now, you could hack up a routine that just sends the calls, sprinkle in
> > a callback routine that's run by cifsd or something when the writes
> > come back (though you'll need to be wary of deadlock, of course).
> >
> >   
> I was assuming the latter ... ie that cifsd processes the completion (or 
> spawns a slow
> work task to process the response).   For the case of write (actually 
> writepages)
> there is not processing to be done (checking the rc, updating the status of
> the corresponding pages in the page cache).   For read there are various 
> choices
> (launching a slow work thread in readpages - but you only need one for what
> is potentially a very large number of reads from that readpages call) or 
> processing
> in cifs or launching a slow work thread to process (my current 
> preference since
> this is just cache updates/readahead anyway).
> 

Fair enough. In fact, I have a patch in my for-2.6.33 branch that
generalizes the callback routine when cifsd matches a response to a
MID. That may help get that moving.

Still, the fact of the matter is that cifs carries a thread (cifsd)
that's wouldn't truly be needed were the responses to be processed in
softirq context as sunrpc does.

> >>
> >> That (splitting decode into a distinct helper) makes sense (at least for 
> >> async capable ops,
> >> in particular write, read and directory change notification and byte 
> >> range locks).  The
> >> "smb_decode_write_response" case is a particularly simple and useful one 
> >> to do and would
> >> be an easy one to do as a test.   I think the prototype patches for 
> >> async write that someone did
> >> for cifs a few years ago did that.
> >>     
> >
> > Even for ops that are fundamentally synchronous, it makes sense to
> > split the encoding and decoding into separate routines. Maybe it's just
> > my personal bias, but I think it encourages a cleaner, more flexible
> > design.
> >   
> I don't have a strong preference either way.   There are a large number 
> of SMBs which
> are basically "responseless" (we just look at the rc, but they don't 
> include parameters)
> so they would not have interesting decode routines.    Even for SMB2 
> although we
> probably have to look at the credits, the generic SMB response 
> processing can
> probably deal with those.   For those SMBs which have response processing,
> if it makes for smaller more readable functions to break out the decode 
> routines, that seems
> fine.
> 

Sure, it's the same way with NFS too. For those we can probably just
use a standard "decode" routine that just looks at the error code. Code
consolidation is a good thing.

> > SMB transport header is 32 bits and contains a length with a zeroed out
> > upper byte. The RPC over TCP transport header is 32 bits and contains a
> > 31 bit length + a "last fragment" flag.
> >
> > SMB has MID's, RPC has XID's
> >
> > RPC has the RPC auth info, SMB has the session UID and TID
> >
> >
> >   
> There are some similar concepts but at different levels of the network 
> stack.  Having
> net/sunrpc assemble SMB headers (uid, mids) would be needed if you 
> really want
> to leverage the similar concepts, and it seems like a strange idea to 
> move much of fs/cifs
> into net/sunrpc helpers
> 

Are they really at different levels of the network stack? SMB/SMB2
carries a little more info within the protocol header than we need at
the transport layer, but it's not really that big a deal. The code I
have just copies off the data until it gets to the MID.

Assembling UID's/TID's etc for a packet I see as more a function for
the credential/auth management code in the RPC layer. Essentially I
think I'll have to write a "RPC_AUTH_SMB" rpc_auth plugin for it and
probably also a corresponding credential piece.

It'll be quite a bit different from how it's handled with "real" RPC
protocols, but should still fit within the basic framework.
 
> >>> The code I've proposed more or less has abstractions along those lines.
> >>> There's:
> >>>
> >>> transport class -- (net/sunrpc/xprtsmb.c)
> >>> header encoding/decoding -- (net/sunrpc/smb.c)
> >>>
> >>> ...the other parts will be implemented by the filesystem (similar to
> >>> how fs/nfs/nfs?xdr.c work).
> >>>
> >>>   
> >>>       
> >>>> I like the idea of the way SunRPC keeps task information, and it may 
> >>>> make it easier
> >>>> to carry credentials around (although I think using Dave Howell's key 
> >>>> management code
> >>>> might be ok instead to access Winbind).   I am not sure how easy it 
> >>>> would be to tie
> >>>> SunRPC credential mapping to Winbind but that could probably be done.  I 
> >>>> like the
> >>>> async scheduling capability of SunRPC although I suspect that it is a 
> >>>> factor in
> >>>> a number of the (nfs client) performance problems we have seen so may 
> >>>> need more work.
> >>>> I don't like adding (in effect) an extra transport and "encoding layer" 
> >>>> though to
> >>>> protocols (cifs and smb2).   NFS since it is built on SunRPC on the 
> >>>> wire, required
> >>>> such a layer, and it makes sense for NFS to layer the code, like their 
> >>>> protocol,
> >>>> over SunRPC.   CIFS and SMB2 don't require (or even allow) XDR translation,
> >>>> variable encodings, and SunRPC encapsulation so the idea of abstracting the
> >>>> encoding of something that has a single defined encoding seems wrong.
> >>>>     
> >>>>         
> >>> I'm not sure I understand this last comment. CIFS/SMB2 and NFS are just
> >>> not that different in this regard. Either way you have to marshal up
> >>> the buffer correctly before you send it, and decode it properly.
> >>>
> >>>   
> >>>       
> >> As an example of one of the more complicated cases for cifs (setting a 
> >> time field).  
> >> The code looks something like this and is very straightforward to see where
> >> the "linux field" is being put into the packet - and to catch errors in 
> >> size or
> >> endianness.   Most cases are simpler for cifs.
> >>
> >> struct file_basic_info buf;  /* the wire format of the file basic info 
> >> SMB info level */
> >>
> >> buf->LastAccessTime = 0;  /* we can't set access time to Windows */
> >> buf->LastWriteTime = cpu_to_le64(cifs_UnixTimeToNT(attrs->ia_atime));
> >> (followed by a few similar assignment statements for the remaining fields)
> >>
> >> then send the SMB header followed by the buffer.   There is no marshalling
> >> or xdr conversion needed.   One thing I like about this approach is that
> >> "sparse" (make modules C=1) immediately catches any mismatch
> >> between the wire format (size or endianness) and the vfs data
> >> structure element being put in the frame.
> >>
> >> Looking at nfs4xdr.c as an example for comparison, it is much harder to 
> >> see the actual line
> >> where a bigendian (or littlenedian) 64 bit quantity is being put into 
> >> the request frame.
> >>
> >>     
> >
> > Woah...I think we just have a difference in terminology here. When I
> > say "encoding" the packet, I just mean that we're stuffing the data
> > into the buffer in the format that the wire expects.
> >
> > Now, whether you do that with packed structures (like CIFS does and
> > which I tend to prefer), or via "hand-marshaling" (like the WRITE/READ
> > macros in the nfs?xdr.c files) is simply an implementation detail.
> >   
> If we are stuffing the data into the buffer in the format the wire 
> expects ie a series of assignment
> statements more or less as we do today (but broken into distinct encode 
> and decode helpers)
> 
> pSMB->SomeField = cpu_to_le64(inode->some_attribute_field);
> 
> and simply using SunRPC as a convenient wrapper around the socket API for
> async dispatch that is probably fine (not sure if it is slower or faster 
> ... and
> RPC has various performance limitations like the RPC_SLOT_COUNT)
> although not sure it is worth the trouble.

Why would it be any extra trouble when you're designing something new
in the first place? As I said above, trying to bolt CIFS onto this is
probably going to be more trouble than its worth. SMB2 is another
matter though.

When it comes to encoding, all of the header and call encoding routines
have a defined set of args and return values. How you actually do the
encoding is up to the person writing the implementation. I too think
that packed structures are easier to deal with and would probably
prefer those over hand-marshaling.

CIFS has a "slot count" limitation too (we default to 50 outstanding
calls). In fact, for the prototype here, I made the slot count default
to 50 because of that precedent.

-- 
Jeff Layton <jlayton@redhat.com>
