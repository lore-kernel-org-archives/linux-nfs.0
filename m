From: Juan Gomez <juang@us.ibm.com>
Subject: Re: Why NFS server does not pass lock requests via VFS lock() op?
Date: Wed, 9 Oct 2002 17:07:19 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OFAB5FE3E3.3D571A56-ON87256C4D.008352AE@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, linux-kernel-owner@vger.kernel.org,
   nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from e6.ny.us.ibm.com ([32.97.182.106])
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 17zQrS-00069y-00
	for <nfs@lists.sourceforge.net>; Wed, 09 Oct 2002 17:07:31 -0700
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>





Oh ok. Well can we resuscitate this patch? The AFS NAS head example is a
good reason to do this.
If you need any help please let me know and I will be happy to test/adapt
the patch in/to the version that you may want to apply it.
We have one version for 2.4.18 that someone created recently if the one you
have is too old...

Thanks, Juan




|---------+---------------------------------->
|         |           Alan Cox               |
|         |           <alan@lxorguk.ukuu.org.|
|         |           uk>                    |
|         |           Sent by:               |
|         |           linux-kernel-owner@vger|
|         |           .kernel.org            |
|         |                                  |
|         |                                  |
|         |           10/09/02 04:32 PM      |
|         |                                  |
|---------+---------------------------------->
  >-----------------------------------------------------------------------------------------------------------------------------|
  |                                                                                                                             |
  |       To:       Juan Gomez/Almaden/IBM@IBMUS                                                                                |
  |       cc:       nfs@lists.sourceforge.net, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>                         |
  |       Subject:  Re: Why NFS server does not pass lock requests via VFS lock() op?                                           |
  |                                                                                                                             |
  |                                                                                                                             |
  >-----------------------------------------------------------------------------------------------------------------------------|



On Thu, 2002-10-10 at 00:11, Juan Gomez wrote:
>
>
>
>
> Could anyone remind me of why NFS kernel would not pass byte range lock
> requests to the underlying filsystem at the server side?
> I think another person at IBM (Brian?) submitted a patch for this but
such
> patch never got included in the distribution.

I know Matthew had the patches, and I know I looked at them and they
seemed sane enough. But I don't know where they eventually went. Things
like NFS over AFS are going to need it

-
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/





-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
