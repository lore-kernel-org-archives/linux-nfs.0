From: Neil Brown <neilb@suse.de>
Subject: Re: Fwd:  nfs-utils compilation failing?
Date: Fri, 21 Jul 2006 17:46:07 +1000
Message-ID: <17600.34367.859069.55173@cse.unsw.edu.au>
References: <OF11F5EA29.FE9B4626-ON882571A8.0071F565-882571A8.0072D28A@us.ibm.com>
	<4d569c330607112009o56e869cfr47d91ad9347ead3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sf.net, Usha Ketineni <uketinen@us.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G3pio-0000aF-O3
	for nfs@lists.sourceforge.net; Fri, 21 Jul 2006 00:46:54 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G3pin-0002NK-Sa
	for nfs@lists.sourceforge.net; Fri, 21 Jul 2006 00:46:55 -0700
To: "Kevin Coffman" <kwc@citi.umich.edu>
In-Reply-To: message from Kevin Coffman on Tuesday July 11
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

On Tuesday July 11, kwc@citi.umich.edu wrote:
> Crap.  This is my fault.  It is the result of re-ordering patches that
> I submitted for 1.0.9.  I have the following in a patch that I haven't
> submitted yet:

:-(  That's a shame.
It's in git and will be in whatever the next release is.

NeilBrown

> 
> diff -puN utils/gssd/write_bytes.h~gssd_handle_cfx_context
> utils/gssd/write_bytes.h
> --- nfs-utils-1.0.9/utils/gssd/write_bytes.h~gssd_handle_cfx_context	2006-07-10
> 14:46:13.929980000 -0400
> +++ nfs-utils-1.0.9-kwc/utils/gssd/write_bytes.h	2006-07-10
> 14:46:14.017955000 -0400
> @@ -63,6 +63,19 @@ write_buffer(char **p, char *end, gss_bu
>  	return 0;
>  }
> 
> +inline static int
> +write_oid(char **p, char *end, gss_OID_desc *arg)
> +{
> +	int len = (int)arg->length;		/* make an int out of size_t */
> +	if (WRITE_BYTES(p, end, len))
> +		return -1;
> +	if (*p + arg->length > end)
> +		return -1;
> +	memcpy(*p, arg->elements, len);
> +	*p += len;
> +	return 0;
> +}
> +
>  static inline int
>  get_bytes(char **ptr, const char *end, void *res, int len)
>  {
> 

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
