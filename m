From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: svc_process and nfsd_proc_read not taking checksum into
	account when calling svc_reserve
Date: Fri, 20 Apr 2007 13:47:48 -0400
Message-ID: <20070420174748.GG19285@fieldses.org>
References: <4628D19F.5080805@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HexD2-00041V-83
	for nfs@lists.sourceforge.net; Fri, 20 Apr 2007 10:47:48 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HexD4-0006GT-I4
	for nfs@lists.sourceforge.net; Fri, 20 Apr 2007 10:47:50 -0700
In-Reply-To: <4628D19F.5080805@redhat.com>
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

On Fri, Apr 20, 2007 at 10:43:43AM -0400, Jeff Layton wrote:
> I think I've finally chased down a bug that I noticed at connectathon 
> this year. When a client mounts a Linux NFS server using NFSv2 or 3 with 
> sec=krb5i, the server gets a ton of messages like this in the logs:
> 
> RPC request reserved 80 but used 124

Great, thanks!

> My thinking is that we need a wrapper of some sort around these calls to 
> svc_reserve that increases the "space" parameter by the amount of the 
> expected checksum. My question is -- is there a simple way to compute 
> the expected length of the checksum, given a svc_rqst?

You don't need to know the exact amount, just an upper bound, right?

In which case I'd be tempted to just look at some krb5i and krb5p
traffic in wireshark, figure out how much it adds (it should always be
the same, except that krb5p pads the arguments to the nearest 8-byte
boundary, which will add padding that varies between 1 and 8 bytes.)

That might not be right for spkm3 (or any other mechanism), but if this
isn't critical then maybe we can ignore that problem for now.

Computing the exact length in general is hard.  (For example, I think
spkm3 encodes the checksum using some wacky asn1 encoding that means
it's shorter if it happens to have enough consecutive zeros in it.... So
you really can't know the exactly length till you've already computed
it.)

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
