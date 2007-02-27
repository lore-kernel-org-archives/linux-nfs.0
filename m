From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 11/11] nfs-utils: mount: Fixed collision between
 commas in options
Date: Tue, 27 Feb 2007 17:35:58 +1100
Message-ID: <17891.53582.325117.716540@notabene.brown>
References: <45E2C289.30506@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Karel Zak <kzak@redhat.com>, nfs@lists.sourceforge.net,
	Cory Olmo <colmo@TrustedCS.com>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HLvxW-0005JP-45
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 22:37:11 -0800
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HLvxX-0004Lh-Uu
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 22:37:12 -0800
In-Reply-To: message from Steve Dickson on Monday February 26
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

On Monday February 26, SteveD@redhat.com wrote:
> commit 96a3ceb3d35bf5edcb9446aded8375d3b98b4f5b
> Author: Cory Olmo <colmo@TrustedCS.com>
> Date:   Sat Feb 24 16:20:40 2007 -0500
> 
>     This patch avoid the collision between commas in security contexts and the
>     delimiter betweeen mount options.
>     
>     Signed-off-by: Karel Zak <kzak@redhat.com>
>     Signed-off-by: Cory Olmo <colmo@TrustedCS.com>
> 
> diff --git a/utils/mount/mount.c b/utils/mount/mount.c
> index b3d3696..f22747b 100644
> --- a/utils/mount/mount.c
> +++ b/utils/mount/mount.c
> @@ -285,18 +285,30 @@ static void parse_opts (const char *options, int *flags, char **extra_opts)
>  {
>  	if (options != NULL) {
>  		char *opts = xstrdup(options);
> -		char *opt;
> -		int len = strlen(opts) + 20;
> -
> +		char *opt, *p;
> +		int len = strlen(opts) + 256;

This is a worry.  If 20 isn't big enough, why do you thing 256 will
be? and where do we check that the buffer doesn't overflow (in this
setuid program).
What are we making space for here?

Would strlen(opts)*2 or *3 be sure to be sufficient?

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
