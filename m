From: Kris Vassallo <kris@linuxcertified.com>
Subject: Re: More Stale NFS handles
Date: Wed, 29 Jun 2005 13:28:07 -0700
Message-ID: <1120076887.8751.34.camel@localhost.localdomain>
References: <449CA531-2B73-458E-B632-B1E159637115@jhu.edu>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="=-YHHejnLFPd0Pbh0ZNyeC"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.91] (helo=sc8-sf-mx1-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DnjAN-0002bo-Pz
	for nfs@lists.sourceforge.net; Wed, 29 Jun 2005 13:28:15 -0700
Received: from meteor.hosting4less.com ([63.99.109.5])
	by sc8-sf-mx1-new.sourceforge.net with esmtp (Exim 4.44)
	id 1DnjAN-00055R-Hn
	for nfs@lists.sourceforge.net; Wed, 29 Jun 2005 13:28:15 -0700
To: Eiwe Lingefors <eiwe@jhu.edu>
In-Reply-To: <449CA531-2B73-458E-B632-B1E159637115@jhu.edu>
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


--=-YHHejnLFPd0Pbh0ZNyeC
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, 2005-06-23 at 13:55, Eiwe Lingefors wrote:

> The server:
> Dell PowerEdge 2850
> 1 x PowerVault 220S 14x300GB SCSI
> Fedora Core 3
> Kernel 2.6.9-1.667smp
> Several exported LVM volumes all formatted with reiserfs v3.6
> So far nothing I have done has helped reduce the amount of stale NFS  
> file handles.

Bah! I have the same problem, I've had it for months now. I was about to
build yet another server and use reiserfs but thanks to you I am spared
the agony of finding out it wont work. 

> 
> I'm not sure what additional information might be helpful. The  
> problems I'm having essentially mirror those of others who have  
> posted regarding stale NFS handles in the past few months on this  
> list. I'm at my wits end after having fought with this problem for  
> weeks.

YES YES YES!!! It almost brings a state of insanity with it!! Plus, atop
my insanity I have a group of 30 developers who are complaining about
not being able to do work because of stale file handles. 

>  Any insight or pointers would be deeply appreciated. I'll be  
> happy to provide additional information if needed.

I was using ext3, upgraded to core 3 from core 1 and had the exact same
problems. What did it for me, until someone fixes this problem, was to
turn off journaling (so basically its back to ext2). Since reverting
back to ext 2 the problem has gone away. Now this is going to be a huge
problem if the machine crashes because fscking a 1.5 TB disk array is
going to suck! I experimented with the way the journaling gets done
(data goes to disk first or journal first) and I wasn't able to fix the
problem. 

Aaaaaaargh! 
I just thought I would share my ongoing battle story, hopefully someone
will figure out what's causing this and will come up with a fix.

-Kris


> 
> Thanks,
> Eiwe Lingefors
> 



--=-YHHejnLFPd0Pbh0ZNyeC
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: 7bit

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 TRANSITIONAL//EN">
<HTML>
<HEAD>
  <META HTTP-EQUIV="Content-Type" CONTENT="text/html; CHARSET=UTF-8">
  <META NAME="GENERATOR" CONTENT="GtkHTML/3.0.10">
</HEAD>
<BODY>
On Thu, 2005-06-23 at 13:55, Eiwe Lingefors wrote:
<BLOCKQUOTE TYPE=CITE>
<PRE><FONT COLOR="#737373"><I>The server:
Dell PowerEdge 2850
1 x PowerVault 220S 14x300GB SCSI
Fedora Core 3
Kernel 2.6.9-1.667smp
Several exported LVM volumes all formatted with reiserfs v3.6
So far nothing I have done has helped reduce the amount of stale NFS  
file handles.</I></FONT></PRE>
</BLOCKQUOTE>
Bah! I have the same problem, I've had it for months now. I was about to build yet another server and use reiserfs but thanks to you I am spared the agony of finding out it wont work. 
<BLOCKQUOTE TYPE=CITE>
<PRE><FONT COLOR="#737373"><I>
I'm not sure what additional information might be helpful. The  
problems I'm having essentially mirror those of others who have  
posted regarding stale NFS handles in the past few months on this  
list. I'm at my wits end after having fought with this problem for  
weeks.</I></FONT></PRE>
</BLOCKQUOTE>
YES YES YES!!! It almost brings a state of insanity with it!! Plus, atop my insanity I have a group of 30 developers who are complaining about not being able to do work because of stale file handles. 
<BLOCKQUOTE TYPE=CITE>
<PRE><FONT COLOR="#737373"><I> Any insight or pointers would be deeply appreciated. I'll be&nbsp; 
happy to provide additional information if needed.</I></FONT></PRE>
</BLOCKQUOTE>
I was using ext3, upgraded to core 3 from core 1 and had the exact same problems. What did it for me, until someone fixes this problem, was to turn off journaling (so basically its back to ext2). Since reverting back to ext 2 the problem has gone away. Now this is going to be a huge problem if the machine crashes because fscking a 1.5 TB disk array is going to suck! I experimented with the way the journaling gets done (data goes to disk first or journal first) and I wasn't able to fix the problem. <BR>
<BR>
Aaaaaaargh! <BR>
I just thought I would share my ongoing battle story, hopefully someone will figure out what's causing this and will come up with a fix.<BR>
<BR>
-Kris<BR>
<BR>
<BLOCKQUOTE TYPE=CITE>
<PRE><FONT COLOR="#737373"><I>
Thanks,
Eiwe Lingefors
</I></FONT></PRE>
</BLOCKQUOTE>
<BR>
</BODY>
</HTML>

--=-YHHejnLFPd0Pbh0ZNyeC--



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
