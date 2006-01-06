From: Blake Golliher <golliher@yahoo-inc.com>
Subject: Re: NFS performance tuning
Date: Fri, 6 Jan 2006 09:47:34 -0800
Message-ID: <32f0438a5087c2ea289922bbacb1897d@local>
References: <43BE9EC3.3090108@totalflood.com>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Euvh4-0000Ji-Id
	for nfs@lists.sourceforge.net; Fri, 06 Jan 2006 09:48:02 -0800
Received: from mrout1-b.corp.dcn.yahoo.com ([216.109.112.27])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Euvh3-0004Z8-8n
	for nfs@lists.sourceforge.net; Fri, 06 Jan 2006 09:48:02 -0800
In-Reply-To: <43BE9EC3.3090108@totalflood.com>
To: Stephen Carville <stephen@totalflood.com>
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

Did you specify using a 32k read and write size, that I didn't see  
somewhere?  If you have a very clean network, you could get an  
advantage of using UDP as well.  I'm not sure which transport you are  
using though.

Oh I see a mention of nfs v2 tcp.  Well, I'd recommend moving to nfs  
v3, using a 64k read/write size, and using UDP.  That might give you  
some gains.  Of course, I'm usually a TCP bigot for nfs transport, but  
for a very clean, almost back to back, dedicated switch type of  
environment, I'll allow it.

-Blake

On Jan 6, 2006, at 8:45 AM, Stephen Carville wrote:

> I have NFS server running on a Dell 2850:
>
>   Name: Amazon
>    CPU: 3000 Mhz Xeon  (X2)
> Memory: 2G
>   Swap: 8G
>     OS: Fedora Core 3
>    NFS: Version 1-4
>
> I export a 150G volume thusly:
>
> /NFS/tigris_backup
> 10.1.1.0/ 
> 24(rw,wdelay,nohide,insecure,root_squash,no_subtree_check,anonuid=65534 
> ,anongid=65534)
>
> The client is a Dell 2650 running Oracle 9i
>
>   Name: Tigris
>    CPU: 3200Mhz Xeon (X2)
> Memory: 8G
>   Swap: 4G
>     OS: Redhat ES 3.2
>    NFS: Version 2/tcp
>
> Both have hyperthreading enabled.
> The machines are connected via a dedicated gigabit switch.
>
> The goal (among others) is to run the nightly RMAN backups of the  
> Oracle
> database to the NFS drive on Amazon where it is backed up to tape  
> later.
> To this end I mount the NFS volume, run the backups, and unmount the  
> volme.
>
> That part works well.  However the thruput on the connection is much
> less than I expected.  Simple file transfers for example give only  
> about:
>
> Using NFS
> Amazon to Tigris: 168 Mbps
> Tigris to Amazon: 104 Mbps
>
> Using ftp
> ssh A to T: 320 Mbps
> ssh T to A  360 Mbps
>
> I can accept that I may never get a full Gigabit per second over copper
> but it still looks like there is room for improvement in the NFS  
> trnsfer
> speeds.
>
> Suggestions?
>
> -- 
> Stephen Carville <stephen@totalflood.com>
> Unix and Network Admin
> Nationwide Totalflood
> 6033 W. Century Blvd
> Los Angeles, CA 90045
> 310-342-3602
>
>
>
> -------------------------------------------------------
> This SF.net email is sponsored by: Splunk Inc. Do you grep through log  
> files
> for problems?  Stop!  Download the new AJAX search engine that makes
> searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
> http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
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
