From: Neil Brown <neilb@suse.de>
Subject: Re: nfs-utils 1.0.8-rc2
Date: Wed, 21 Dec 2005 13:59:21 +1100
Message-ID: <17320.50441.923081.501789@cse.unsw.edu.au>
References: <17314.22172.913247.595571@cse.unsw.edu.au>
	<17319.46982.772021.518625@cse.unsw.edu.au>
	<43A7DA2F.8090902@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EouCX-0002Yg-UT
	for nfs@lists.sourceforge.net; Tue, 20 Dec 2005 18:59:37 -0800
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EouCW-000431-R4
	for nfs@lists.sourceforge.net; Tue, 20 Dec 2005 18:59:38 -0800
To: =?ISO-8859-1?Q?Aur=E9lien_Charbon?= <aurelien.charbon@ext.bull.net>
In-Reply-To: message from Aurélien Charbon on Tuesday December 20
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

On Tuesday December 20, aurelien.charbon@ext.bull.net wrote:
> Hi Neil,
> 
> There is a problem in rquotad compilation when compiling nfs-utils on a 
> SLES 9 for ppc64:

Yes... (grumble...)
The quota syscall interface to the kernel changed substantially in
2.6, with no back-comparability support for old applications.
(It is easy to tell which interface to use, so it isn't hard to write
portable apps, but old apps just break).

The
  #define _LINUX_QUOTA_VERSION 1
that we put in allows it to compile on SL10 and newer Redhat etc, but 
the code created won't work on 2.6 :-(

I guess I'd better fix it....

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
