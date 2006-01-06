From: Stephen Carville <stephen@totalflood.com>
Subject: Re: NFS performance tuning
Date: Fri, 06 Jan 2006 11:30:14 -0800
Message-ID: <43BEC546.1010906@totalflood.com>
References: <43BE9EC3.3090108@totalflood.com> <1136567265.7839.25.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EuxI4-0005Xo-Uc
	for nfs@lists.sourceforge.net; Fri, 06 Jan 2006 11:30:20 -0800
Received: from [209.189.103.195] (helo=mail.totalflood.com)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EuxI3-0004BH-NY
	for nfs@lists.sourceforge.net; Fri, 06 Jan 2006 11:30:20 -0800
To: NFS List <nfs@lists.sourceforge.net>
In-Reply-To: <1136567265.7839.25.camel@lade.trondhjem.org>
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

Trond Myklebust wrote:
> On Fri, 2006-01-06 at 08:45 -0800, Stephen Carville wrote:
> 
>>I have NFS server running on a Dell 2850:
>>
>>   Name: Amazon
>>    CPU: 3000 Mhz Xeon  (X2)
>>Memory: 2G
>>   Swap: 8G
>>     OS: Fedora Core 3
>>    NFS: Version 1-4
>>
>>I export a 150G volume thusly:
>>
>>/NFS/tigris_backup
>>10.1.1.0/24(rw,wdelay,nohide,insecure,root_squash,no_subtree_check,anonuid=65534,anongid=65534)
>>
>>The client is a Dell 2650 running Oracle 9i
>>
>>   Name: Tigris
>>    CPU: 3200Mhz Xeon (X2)
>>Memory: 8G
>>   Swap: 4G
>>     OS: Redhat ES 3.2
>>    NFS: Version 2/tcp
> 
> 
> Why are you using NFSv2? That forces the server to use synchronous
> writes (i.e. each write must be committed to disk before the server
> replies to the client) and is very inefficient.
> 
> If your application is write-intensive, you should always choose NFSv3
> or greater.

No problem.  I added nfsvers=3 to the mount options and I'll see how it 
works tonight

-- 
Stephen Carville <stephen@totalflood.com>
Unix and Network Admin
Nationwide Totalflood
6033 W. Century Blvd
Los Angeles, CA 90045
310-342-3602


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
