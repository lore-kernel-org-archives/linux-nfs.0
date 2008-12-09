From: Jeff Layton <jlayton@redhat.com>
Subject: Re: possible module refcount leak with auth_gss
Date: Tue, 9 Dec 2008 15:38:49 -0500
Message-ID: <20081209153849.6605559a@tleilax.poochiereds.net>
References: <20081208102855.30081708@tleilax.poochiereds.net>
	<20081208173706.GE16628@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20081208173706.GE16628@fieldses.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 8 Dec 2008 12:37:06 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Dec 08, 2008 at 10:28:55AM -0500, Jeff Layton wrote:
> > We had someone report a bug against Fedora that they were seeing very
> > high module reference counts for some krb5 related modules on his nfs
> > server. For instance:
> > 
> > # lsmod
> > Module                  Size  Used by
> > des_generic            25216  52736 
> > cbc                    12160  52736 
> > rpcsec_gss_krb5        15632  26370 
> > 
> > ...the cbc and des_generic each have roughly 2 module references per
> > rpcsec_gss_krb5 refcount so I'm assuming that the "lynchpin" here is
> > the rpcsec_gss_krb5 refcount which seems to be increasing w/o bound.
> 
> You may want to see this discussion:
> 
> 	http://marc.info/?t=122819524700001&r=1&w=2
> 
> And these patches:
> 
> 	http://marc.info/?l=linux-nfs&m=122843371318602&w=2
> 

Doh! I saw that discussion and didn't make the connection. Thanks for
pointing that out.

> In addition to increasing the timeouts on those cache entries, perhaps
> we could flush the contexts on rmmod?  Or change the reference counting
> somehow--e.g., take a reference only in the presence of export cache
> entries that mention krb5, and destroy contexts when the last such goes
> away?
> 

That sounds like a better scheme than what we have currently. As it stands
now, you can't just unplug the module -- you have to wait for the entries
in the cache to time out.

FWIW, I tested out Kevin's patches and it still didn't seem to help. The
refcounts never seemed to go down (even after several hours). How long
should the context live in the cache with those patches? Until the krb5
ticket expires? I'll leave the box in this state until around this time
tomorrow to be sure (that's when the ticket expires).

> Also to check: a recent client should be sending destroy_ctx calls on
> unmount, and a recent server should be acting on them.  Perhaps there's
> a bug there.  I'd do an unmount, watch the wire to make sure the
> destroy_ctx calls are really going across (they'll look like NFSv4 NULL
> calls, with the interesting fields in the cred in the rpc header).  Then
> take a close look at the destroy_ctx code (see the second occurence of
> RPC_GSS_PROC_DESTROY in svcauth_gss_accept(), around line 1126).
> 

I didn't have 2 hosts with recent kernels, so I tested this on a
machine with a recent kernel mounting itself. The kernel was:

2.6.28-0.121.rc7.git5.fc11.x86_64

(relatively recent pull from Linus tree AFAIK)

On host foo.bar.baz:

# mount -t nfs4 -o sec=krb5 foo.bar.baz:/ /mnt/test
# umount /mnt/test

The refcount on the module went up by 1 after this. I also did a
capture on port 2049. During the unmount, I didn't see any RPC activity
between client and server. The only thing I see is the socket being
closed:

 36   1.584397 10.11.231.229 -> 10.11.231.229 TCP 1016 > nfs [FIN, ACK] Seq=1377 Ack=1389 Win=40320 Len=0 TSV=1648278 TSER=1646778
 37   1.584551 10.11.231.229 -> 10.11.231.229 TCP nfs > 1016 [FIN, ACK] Seq=1389 Ack=1378 Win=41344 Len=0 TSV=1648278 TSER=1648278
 38   1.584614 10.11.231.229 -> 10.11.231.229 TCP 1016 > nfs [ACK] Seq=1378 Ack=1390 Win=40320 Len=0 TSV=1648278 TSER=1648278

It looks like the destroy_ctx isn't working AFAICT. I haven't started
digging into the code yet to figure out why however.

Thanks for the info so far.

Cheers,
-- 
Jeff Layton <jlayton@redhat.com>
