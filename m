From: "Roger Heflin" <rheflin@atipa.com>
Subject: RE: mtime not updated in client cache?
Date: Fri, 9 Dec 2005 13:55:26 -0600
Message-ID: <EXCHG2003JY4kJSFsxf000003dd@EXCHG2003.microtech-ks.com>
References: <4399D8FC.1020400@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EkoCT-0002Po-T6
	for nfs@lists.sourceforge.net; Fri, 09 Dec 2005 11:46:37 -0800
Received: from host27-37.discord.birch.net ([65.16.27.37] helo=EXCHG2003.microtech-ks.com)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EkoCR-0007jV-LI
	for nfs@lists.sourceforge.net; Fri, 09 Dec 2005 11:46:38 -0800
To: "'Peter Staubach'" <staubach@redhat.com>,
	"'Lever, Charles'" <Charles.Lever@netapp.com>
In-Reply-To: <4399D8FC.1020400@redhat.com>
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

 

> -----Original Message-----
> From: nfs-admin@lists.sourceforge.net 
> [mailto:nfs-admin@lists.sourceforge.net] On Behalf Of Peter Staubach
> Sent: Friday, December 09, 2005 1:20 PM
> To: Lever, Charles
> Cc: nfs@lists.sourceforge.net
> Subject: Re: [NFS] mtime not updated in client cache?
> 
> Lever, Charles wrote:
> 
> >
> >risks understood.
> >
> >however, how is this different from ext3?  a close() on an ext3 file 
> >doesn't even attempt to schedule a flush of the data to 
> disk.  if the 
> >system crashes or the disk dies or the file system fills up, 
> the data 
> >is lost, just like in the NFS case.
> >  
> >
> 
> I think that the difference is that a system crash also 
> terminates the application and there is just more visibility 
> into what happened.

On a local machine, the application can complete successfully, 
and the data won't be written out for up to 30 seconds, and this
can be higher on machines that have huge amounts of ram, and can
hold a lot more in its write cache, so data can be
lost even after the program completes properly if the machine crashes
before the writes are finished.

If you get a hard scsi/disk error when writing data from local cache, there
is not a process to return that error to the program that generated
the data assuming that the program is even still running.

                           Roger



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
