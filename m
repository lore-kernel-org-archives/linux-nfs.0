From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] RPC: add wrapper for svc_reserve to account
	for	checksum
Date: Wed, 2 May 2007 15:36:25 -0400
Message-ID: <20070502193622.GD23041@salusa.poochiereds.net>
References: <20070421131523.GA18100@dantu.rdu.redhat.com>
	<17974.41587.666167.650575@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	Jeff Layton <jlayton@redhat.com>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HjKcq-0002W8-QN
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 12:36:43 -0700
Received: from ms-smtp-01.southeast.rr.com ([24.25.9.100])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HjKct-00039l-4D
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 12:36:35 -0700
In-Reply-To: <17974.41587.666167.650575@notabene.brown>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Tue, May 01, 2007 at 12:14:11PM +1000, Neil Brown wrote:
> On Saturday April 21, jlayton@redhat.com wrote:
> > When the kernel calls svc_reserve to downsize the expected size of an RPC
> > reply, it fails to account for the possibility of a checksum at the end of
> > the packet. If a client mounts a NFSv2/3 with sec=krb5i/p, and does I/O then
> > you'll generally see messages similar to this in the server's ring buffer:
> > 
> > RPC request reserved 164 but used 208
> > 
> > While I was never able to verify it, I suspect that this problem is also the
> > root cause of some oopses I've seen under these conditions:
> > 
> > https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=227726
> 
> I don't think to two are that closely related.
> The space reservation mentioned in the "RPC request reserved ..."
> messages is a fairly soft reservation.  We try to make sure the
> network stack reserves a certain amount of space, then try never to
> start processing a request unless we will be able to reply without
> exceeding that allocation.
> If we get it wrong and do exceed the allocation, the worst that might
> happen is that we might block while writing the reply and maybe have
> to close a connection, or send out an incomplete packet, or something
> like that.  Certainly not an oops.
> 
> The extra space needed at the end of the message of integrity
> information which we weren't accounting for properly does seemed to be
> accounted correctly in svcauth_gss_wrap_resp_integ (I'm less sure of
> _wrp_resp_priv, but it is probably right).
> 
> Of the two Oops in that BUG, the first seems to be the
> 		BUG_ON(resbuf->tail[0].iov_len);
> in svcauth_gss_wrap_resp_integ (assuming code in 2.6.9-44.ELxenU is at
> least vaguely similar to current -mm).
> 
> I don't think this BUG_ON is correct.  If a readdir finds zero entries,
> then will be some trailer information in the 'tail', but page_len will
> be 0.  I think the following patch is correct and could fix that.
> Bruce:  does it look OK to you?
> 
> 
> The second oops is harder to interpret.
> I looks like tcp_send_page is getting a NULL page, though it could be
> getting a length > PAGE_SIZE which might have the same effect.
> 
> It reminds me of
>   http://bugzilla.kernel.org/show_bug.cgi?id=7795
> but I'm not convinced it is the same.
> 
> > 
> > Unfortunately, there doesn't seem to be a good way to reliably determine the
> > expected checksum length prior to actually calculating it, particularly with
> > schemes like spkm3.
> 
> Yes, that asn1 encoding does seem rather awkward.
> 
> Maybe we should just use RPC_MAX_AUTH_SIZE like other bits of GSS code
> does.  There is no great cost in reserving too much space - it just
> might slow things down a little when tight on memory.
> What would you think of submitting an incremental patch which replaces
> the "56" with "RPC_MAX_AUTH_SIZE" ?
> 
> Thanks (and sorry for the delay).
> NeilBrown
> 
> --
> Simplify (and fix) adding of integrity data to end of rpc message
> 
> There is no value in a special case for adding integ data to the
> 'head' part of the reply in the case where there is no body.
> Always put it in the 'tail', placing that after the current head if it
> doesn't have a place yet.
> As readdir can potentially return an empty body and a non-empty tail,
> the BUG_ON can fire.
> 
> Signed-off-by: Neil Brown <neilb@suse.de>
> 

Just got through testing this patch. Unfortunately, this panic seems to much
more difficult for me to reproduce all of a sudden. I saw it quite a few
times at connectathon, but I've tried to get it to occur on fairly recent
kernels today and haven't been able to. Perhaps some other change is papering
over it somehow.

The patch doesn't seem to break anything, but I can't really confirm whether
it fixes these oopses. Still, it seems like a sensible change AFAICT...

-- Jeff


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
