From: Jan Bruvoll <jan@bruvoll.com>
Subject: Re: async vs. sync
Date: Tue, 27 Jul 2004 15:11:27 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4106628F.50902@bruvoll.com>
References: <482A3FA0050D21419C269D13989C61130435E51E@lavender-fe.eng.netapp.com> <200407270006.08581.bernd-schubert@web.de> <410643C5.3040004@bruvoll.com> <200407271500.38074.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: NFS mailling list <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BpSgA-0000Wr-5z
	for nfs@lists.sourceforge.net; Tue, 27 Jul 2004 07:11:42 -0700
Received: from homer.brvl.com ([213.61.99.172])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1BpSg9-00037A-MZ
	for nfs@lists.sourceforge.net; Tue, 27 Jul 2004 07:11:42 -0700
To: Bernd Schubert <bernd-schubert@web.de>
In-Reply-To: <200407271500.38074.bernd-schubert@web.de>
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

Hi again,

Bernd Schubert wrote:

> Certainly not. We have 45 diskless booting clients.

I should maybe add that these 12 clients are a web server farm for one 
of the largest national web sites. However, raw throughput is not the 
problem.

Weirder still is that the server seems to lose interest every now and 
then - I've been running tests with 2-3 clients and everything is ok, 
then I add another client or incur some write activity to the shared 
disk and suddenly the server just goes quiet - the clients hang, the 
server does nothing (not even disk writes), and it continues like that 
for 10-15 secs, then everything clears up again until the next clog-up 
30 secs down the line.

Are there any known issues with DRBD perhaps? Didn't think that would be 
such a throughput hog?

> Which nfs-utils version is running on that server? With 1.0 the 
> default changed from async to sync. I guess you only did security 
> updates from your distribution and so there's <=0.3 installed


This is of course highly interesting. You're quite correct, our old 
server runs nfs-utils-0.3.1.

>With 2.6.7 it helped us a lot to give the no_wdelay option, maybe you should 
>try it as well.
>  
>

Haven't made the big leap to 2.6.x yet, especially not after reading 
your own comment on stability issues with 2.6.7.

>You should make sure, that rsize and wsize are set to 8192 (cat /proc/mounts 
>tells you the current value). Also, just try to use tcp-mounts, if you have 
>an asynchronous net (e.g. the server and switch have a GBit interface, but 
>the clients only 100MBit) this is necessary anyway. The same if the clients 
>or server are using linux-2.6.x.
>  
>

Ok - will try these things too.

Thanks
Jan



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
