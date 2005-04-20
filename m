From: Steven <steven@void.org>
Subject: Re: NFS crash problem in readdirplus
Date: Wed, 20 Apr 2005 11:34:37 -0700
Message-ID: <20050420183438.10F691165A4@dead.void.org>
References: <20050401173053.32F551154F4@dead.void.org>  <20050420084935.GA30863@suse.de>
Cc: Steven <steven@void.org>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DOK3V-0008UD-VZ
	for nfs@lists.sourceforge.net; Wed, 20 Apr 2005 11:36:09 -0700
Received: from dsl092-218-023.sfo2.dsl.speakeasy.net ([66.92.218.23] helo=chaotic.void.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DOK3U-0002nd-JO
	for nfs@lists.sourceforge.net; Wed, 20 Apr 2005 11:36:09 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: Message from Olaf Kirch <okir@suse.de>
   of "Wed, 20 Apr 2005 10:49:35 +0200." <20050420084935.GA30863@suse.de>
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

Right, resp->buffer is set here;

int
nfs3svc_decode_readdirplusargs(struct svc_rqst *rqstp, u32 *p,
					struct nfsd3_readdirargs *args)
{
	int len, pn;

	if (!(p = decode_fh(p, &args->fh)))
		return 0;
	p = xdr_decode_hyper(p, &args->cookie);
	args->verf     = p; p += 2;
	args->dircount = ntohl(*p++);
	args->count    = ntohl(*p++);

	len = (args->count > NFSSVC_MAXBLKSIZE) ? NFSSVC_MAXBLKSIZE :
						  args->count;
	args->count = len;

	while (len > 0) {
		pn = rqstp->rq_resused;
		svc_take_page(rqstp);
		if (!args->buffer)
here -->		args->buffer = page_address(rqstp->rq_respages[pn]);
		len -= PAGE_SIZE;
	}

	return xdr_argsize_check(rqstp, p);
}

If len == 0 then the conditional on that loop never holds and
args->buffer is never set.

I think that a maxcount of 0 is an invalid argument.  The rfc says that
the size must include all XDR overhead so there is no way to reply
successfully when maxcount is 0.

--Steven



-------------------------------------------------------
This SF.Net email is sponsored by: New Crystal Reports XI.
Version 11 adds new functionality designed to reduce time involved in
creating, integrating, and deploying reporting solutions. Free runtime info,
new features, or free trial, at: http://www.businessobjects.com/devxi/728
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
