From: Olaf Kirch <okir@suse.de>
Subject: Re: NFS crash problem in readdirplus
Date: Wed, 20 Apr 2005 10:49:35 +0200
Message-ID: <20050420084935.GA30863@suse.de>
References: <20050401173053.32F551154F4@dead.void.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DOAtx-0002V1-1j
	for nfs@lists.sourceforge.net; Wed, 20 Apr 2005 01:49:41 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1DOAtv-0001Zl-HY
	for nfs@lists.sourceforge.net; Wed, 20 Apr 2005 01:49:40 -0700
To: Steven <steven@void.org>
In-Reply-To: <20050401173053.32F551154F4@dead.void.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Fri, Apr 01, 2005 at 09:30:53AM -0800, Steven wrote:
> A readdirplus call with count=0 reliably causes a server crash due to a
> null pointer dereference.  The relevant information from my 
> /var/log/messages is at the end of this message.

According to your Oops, it dies here:

int
nfs3svc_encode_readdirres(struct svc_rqst *rqstp, u32 *p,
                                        struct nfsd3_readdirres *resp)
{
        p = encode_post_op_attr(rqstp, p, &resp->fh);

        if (resp->status == 0) {
                /* stupid readdir cookie */
                memcpy(p, resp->verf, 8); p += 2;
                xdr_ressize_check(rqstp, p);
		p = resp->buffer;
here -->>       *p++ = 0;               /* no more entries */
                *p++ = htonl(resp->common.err == nfserr_eof);

resp->buffer is NULL because no entries were encoded. This was fixed
by Neil in 2.6.9.

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax


-------------------------------------------------------
This SF.Net email is sponsored by: New Crystal Reports XI.
Version 11 adds new functionality designed to reduce time involved in
creating, integrating, and deploying reporting solutions. Free runtime info,
new features, or free trial, at: http://www.businessobjects.com/devxi/728
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
