From: James Chamberlain <jamesc@exa.com>
Subject: Re: OT: RAID perf doldrums: advice/recommendations?
Date: Fri, 28 Oct 2005 11:31:55 -0400 (EDT)
Message-ID: <Pine.LNX.4.63.0510281029570.9348@hawking.exa.com>
References: <20051028032149.14201.qmail@web51905.mail.yahoo.com>
 <4361E6BD.2060701@stams.strath.ac.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: email builder <emailbuilder88@yahoo.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EVWD7-0000e6-98
	for nfs@lists.sourceforge.net; Fri, 28 Oct 2005 08:32:05 -0700
Received: from fermi.exa.com ([149.65.3.1])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EVWD6-0002yt-Qn
	for nfs@lists.sourceforge.net; Fri, 28 Oct 2005 08:32:05 -0700
To: Ian Thurlbeck <ian@stams.strath.ac.uk>
In-Reply-To: <4361E6BD.2060701@stams.strath.ac.uk>
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

Hi List,

I was having some performance problems too, a while back.  I don't know that 
performance is now as good as it could possibly be, but it is substantially 
better than it was.  I'm not sure the problems I faced are related to those 
described below, but I'll share them anyway in the hope that someone finds 
them useful.

I have two NFS servers which are basically clones of each other, from a 
hardware perspective.  One was set up with Red Hat 8.0, and the other was 
running Red Hat Enterprise 3.  That becomes important later.  Both have Intel 
SE7500CW2 motherboards and 3Ware 7506 RAID controllers.

When I set up the first system, I noticed that I was having all sorts of 
trouble with the gigabit card.  I'll just paste in some of my notes:

# This next line comes to us from Intel.  The SE7500CW2 motherboard which we
# are using has a bit of a problem, in combination with its Intel
# Gigabit card.  When using any version of the e1000 driver newer than 4.3.15,
# we would get all sorts of messages in the syslog saying, "NETDEV WATCHDOG:
# eth0: transmit timed out".  The card would then go offline for a number of
# seconds (10-15) while it reset itself.  This happened quite frequently and
# was highly undesirable behavior in an NFS server.  After much conferring with
# Intel (linux.nic@intel.com), it was determined that there was a cache
# coherency issue with the ICH (Southbridge) device on our SE7500CW2, and that
# setting bit 13 in the 0x50 register of the ICH would alter its behavior with
# regard to prefetch flushing of the cache.  Notes from Intel indicated that
# this device would probably be at Bus 0, Device 0x1E, Func 0, Vendor ID 8086,
# Device ID 244E.  This was confirmed with "lspci" and "pcitweak -l".  The
# original value in register 0x50 was 0x00001402.  A bitwise OR with 0x00002000
# resulted in the new value, 0x00003402.  This fix does not persist across
# reboots, which is why it had to be entered into this file.  Special thanks
# goes to Colleen of Intel Support, who put in a lot of effort to help me get
# this fixed.

The other problem we noticed is that the server with RH8 had pretty decent 
NFS performance, where the RHEL3 system seemed very slow.  After a lot of 
conferring with Red Hat on this, I was told that it was because of the change 
from async to sync as the default for exports and that I should specify async 
when exporting.  I asked them about the safety of this (FAQ: B6), but don't 
recall getting much by way of response; however, since performance *was* 
better with async and since the complaints about performance were very loud, 
I had little choice but to stick with that.

The other thing I've done to (hopefully) improve performance was to increase 
the number of NFS threads being spawned, and give them each a bunch of memory 
([rw]mem_{default,max}).  I figure these boxes are NFS servers and they've 
got the memory to spare, so I may as well dedicate that memory to what 
they're supposed to be doing.  I can't speak to the "Extremely high iowait 
with 3Ware array and moderate disk activity", but if anyone hears anything 
about that, I'd certainly be interested in hearing as well.

James


As always, standard disclaimers apply.  I don't speak for my company, what 
works for me may not work for you, etc.

On Fri, 28 Oct 2005, Ian Thurlbeck wrote:

> email builder wrote:
>> Hello,
>>
>>   Recently we turned on a RAID-backed NFS server that fell flat on its face
>> as soon as it started to see even moderate activity (particularly IMAP
>> traffic from Courier-IMAP).  Through help on the Courier mailing list, the
>> problem appears to be very poor throughput to our hard drives (although
>> systems is not my strong point, so I hope there is not something else I've
>> overlooked).
>>
>>   Our choice to go with consumer-grade hardware seems to have bit us hard. 
>> We are using the oft-maligned 3Ware 85xx series RAID5 controller and three
>> Hitachi Deskstar 7k250 (250GB) SATA drives.  The NFS serves up the 
>> mailstore
>> for a system that does about 60 mail messages/min, plus IMAP against the
>> mailstore (which is what brings the hurt), and some moderately (much more
>> than Joe Bob's homepage, but not Slashdot) trafficed web content.  We were
>> able to buy some time by moving our (ext3) journal off of the same device,
>> fiddle with a couple NFS settings (nodiratime,noatime), but it is still
>> woefully slow.
>>
>>   Are we completely wrong to give up on this hardware?  If anyone is
>> interested in giving advice in that realm, I am happy to provide more stats
>> (like the fact that the machine sits at near 100% iowait all day long).
>
>
> Hi
>
> We noticed similar issues which we never tracked down, even after help from 
> this list.  There is a huge bug report at Redhat entitled:
>
> "Extremely high iowait with 3Ware array and moderate disk activity"
>
> https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=121434
>
> which may be of some help, but it never quite gets to the bottom
> of things.  3ware cards/drivers seem to the common factor in most if
> not all of the "me too's", but of course everyone with a 3ware problem would 
> find this bug report...
>
> Cheers
>
> Ian
>


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.
Get Certified Today * Register for a JBoss Training Course
Free Certification Exam for All Training Attendees Through End of 2005
Visit http://www.jboss.com/services/certification for more information
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
