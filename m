From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: PATCH - SUNRPC 1 of 3 - The new "sk_flags" word in struct svc_sock must be long....
Date: Tue, 20 Aug 2002 18:53:57 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020820185357.O21269@redhat.com>
References: <15713.50328.541517.124690@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from to-velocet.redhat.com ([216.138.202.10] helo=touchme.toronto.redhat.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17hHsv-0000ta-00
	for <nfs@lists.sourceforge.net>; Tue, 20 Aug 2002 15:54:01 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <15713.50328.541517.124690@notabene.cse.unsw.edu.au>; from neilb@cse.unsw.edu.au on Tue, Aug 20, 2002 at 02:24:56PM +1000
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

On Tue, Aug 20, 2002 at 02:24:56PM +1000, Neil Brown wrote:
> @@ -22,7 +22,7 @@ struct svc_sock {
>  
>  	struct svc_serv *	sk_server;	/* service for this socket */
>  	unsigned char		sk_inuse;	/* use count */
> -	unsigned int		sk_flags;
> +	unsigned long		sk_flags;

Cool, 7 bytes of useless padding on 64 bit architectures.

		-ben
-- 
"You will be reincarnated as a toad; and you will be much happier."


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
