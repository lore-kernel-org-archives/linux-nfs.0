From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: RE: Debian Bug#203077: Locks not released on NFS client reboot
Date: Fri, 14 Jan 2005 22:44:03 -0700 (MST)
Message-ID: <Pine.LNX.4.60.0501142237250.11608@harp.ngdc.noaa.gov>
References: <482A3FA0050D21419C269D13989C61130853961D@lavender-fe.eng.netapp.com>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CpgjG-0007tb-BW
	for nfs@lists.sourceforge.net; Fri, 14 Jan 2005 21:44:06 -0800
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CpgjE-0003sK-Vl
	for nfs@lists.sourceforge.net; Fri, 14 Jan 2005 21:44:06 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C61130853961D@lavender-fe.eng.netapp.com>
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

On Fri, 14 Jan 2005, Lever, Charles wrote:

>>>> i poked around the nfs-fag and how-to and didn't see this... if i
>>>> didn't miss it (quite possible) may suggest it be added?
>>>
>>> so far this has not been a common issue, but i will consider it.
>>
>> great.  it may not be common but it is, for a developer,
>> __extrememely__ difficult to debug.  i guaruntee every
>> government lab will have this issue without knowing it
>> because of increased security policies.
>
> general question, then:  what can we add to the client or server
> implementation to make it easier to diagnose?

the hostname of the node holding a lock would be awesome.  unless i am
mistaken (normally ;-)) fcntl will only tell you the pid of the process
holding the lock - not the hostname.  this info in /proc/locks would be great
too.  if that were easy to get at it would be easy for an application to
detect stale locks.  i guess general (userland) meta-data from the nfs server
on files would be great (who has it locked, for how long, etc) - but i realize
this is severly limited by the vfs layer.

cheers.

-a
-- 
===============================================================================
| EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
| PHONE   :: 303.497.6469
| When you do something, you should burn yourself completely, like a good
| bonfire, leaving no trace of yourself.  --Shunryu Suzuki
===============================================================================


-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
