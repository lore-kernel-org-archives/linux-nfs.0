From: Neil Brown <neilb@suse.de>
Subject: Re: nfs-utils 1.0.8-rc1
Date: Mon, 19 Dec 2005 11:29:47 +1100
Message-ID: <17317.65275.664776.566922@cse.unsw.edu.au>
References: <17314.22172.913247.595571@cse.unsw.edu.au>
	<43A2DEEA.7040707@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Eo8ug-0002L5-VI
	for nfs@lists.sourceforge.net; Sun, 18 Dec 2005 16:30:02 -0800
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Eo8uf-000735-K7
	for nfs@lists.sourceforge.net; Sun, 18 Dec 2005 16:30:03 -0800
To: =?ISO-8859-1?Q?Aur=E9lien_Charbon?= <aurelien.charbon@ext.bull.net>
In-Reply-To: message from Aurélien Charbon on Friday December 16
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

On Friday December 16, aurelien.charbon@ext.bull.net wrote:
> Neil Brown wrote:
> 
> >I have just make a RC release for nfs-utils.
> >nfs-utils-1.0.8-rc1 can be found at
> >
> >  http://sourceforge.net/project/showfiles.php?group_id=14
> >or (soon) at
> >  http://www.{countrycode}.kernel.org/pub/linux/utils/nfs/
> >
> >There have been an assortment of bugfixes and improvements over the 
> >past year, but nothing major.
> >As I haven't done much testing myself, I am making this an -rc release
> >and hoping that other will test it.
> >
> I have tested it with fsx and fsstress (3 hour run)
> There is obviously no regression


Thanks.  That's helpful.

However nfs-utils is more active at mount/unmount time and during IO.
A really good test would have lots of clients mounting and unmounting,
and servers and clients crashing, and lots of weird options in
/etc/exports.  That's probably a little hard to manage in a controlled
environment.  

Thanks,
NeilBrown




-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
