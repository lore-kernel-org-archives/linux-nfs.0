From: Neil Brown <neilb@suse.de>
Subject: Re: nfs-utils mount build fails due to missing fsloc.h
Date: Sat, 3 Mar 2007 18:23:40 +1100
Message-ID: <17897.8828.469098.120385@notabene.brown>
References: <E1HNG8e-0000Y8-Ha@externalmx-1.sourceforge.net>
	<01AE8AF878612047A442668306EAEB055C3FE2@SACEXMV01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Muntz, Daniel" <Dan.Muntz@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HNObu-0007ud-F9
	for nfs@lists.sourceforge.net; Fri, 02 Mar 2007 23:24:54 -0800
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HNObv-0001q0-8n
	for nfs@lists.sourceforge.net; Fri, 02 Mar 2007 23:24:56 -0800
In-Reply-To: message from Muntz, Daniel on Friday March 2
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

On Friday March 2, Dan.Muntz@netapp.com wrote:
> Hi all,
>  
> When I pull nfs-utils from the git repository, mountd fails to build due
> to a missing .h file (fsloc.h).  This has been the case for some time
> now.  I originally thought I had just pulled at a bad time (in the
> middle of an update), but when I pulled a 1.0.12+ branch today, I hit
> the same problem.
>  
> I'm just doing:
>  
>     git clone git://git.linux-nfs.org/nfs-utils

The adding a
      git reset --hard nfs-utils-1-0-12

The main branch is a bit broken at the moment, probably get fixed next
week. (I would have expected to want a 'git checkout' comment, but
that doesn't seem to do that right thing).

NeilBrown

>     sh autogen.sh 
>     ./configure 
>     make
>  
> The dependencies I currently have listed for building/running nfs-utils
> are: libevent (1.3a), libnfsidmap (0.19), libgssapi (0.10), librpcsecgss
> (0.14), and various Kerberos bits (1.6 from MIT).
>  
> Is there something else I need to do/undo to get the latest tree to
> build?
>  
>   -Dan

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
