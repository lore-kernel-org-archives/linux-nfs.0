From: Kevin Coffman <kwc@citi.umich.edu>
Subject: Re: nfs-utils 1.0.8-rc1
Date: Fri, 16 Dec 2005 09:21:38 -0500
Message-ID: <4d569c330512160621u4cd1a047g2a838e0dbf8963e8@mail.gmail.com>
References: <17314.22172.913247.595571@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EnGSq-0002PX-5J
	for nfs@lists.sourceforge.net; Fri, 16 Dec 2005 06:21:40 -0800
Received: from zproxy.gmail.com ([64.233.162.195])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EnGSp-0002KE-Qw
	for nfs@lists.sourceforge.net; Fri, 16 Dec 2005 06:21:40 -0800
Received: by zproxy.gmail.com with SMTP id 12so691709nzp
        for <nfs@lists.sourceforge.net>; Fri, 16 Dec 2005 06:21:38 -0800 (PST)
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17314.22172.913247.595571@cse.unsw.edu.au>
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

Hi Neil,
One patch that I didn't include in the bundle I sent yesterday is to
change the build system to use gnu autotools.  I was waiting on some
feedback before sending this one along to you.  Perhaps it would get
more exposure if it was in a release candidate -- if you're willing...

K.C.

On 12/16/05, Neil Brown <neilb@suse.de> wrote:
>
> I have just make a RC release for nfs-utils.
> nfs-utils-1.0.8-rc1 can be found at
>
>   http://sourceforge.net/project/showfiles.php?group_id=3D14
> or (soon) at
>   http://www.{countrycode}.kernel.org/pub/linux/utils/nfs/
>
> There have been an assortment of bugfixes and improvements over the
> past year, but nothing major.
> As I haven't done much testing myself, I am making this an -rc release
> and hoping that other will test it.  I hope to make a real 1.0.8
> in late January, so if anyone has some patches they have been saving
> up, or knows of some annoying problems with nfs-utils, speak now.
>
> NeilBrown 16-December-2005
>
>
> -------------------------------------------------------
> This SF.net email is sponsored by: Splunk Inc. Do you grep through log fi=
les
> for problems?  Stop!  Download the new AJAX search engine that makes
> searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
> http://ads.osdn.com/?ad_id=3D7637&alloc_id=3D16865&op=3Dclick
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>
>


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
