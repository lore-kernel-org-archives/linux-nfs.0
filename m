From: Brashers_Per@emc.com
Subject: Re: NFSv4 and client caching to local disk?
Date: Thu, 3 Apr 2003 11:31:21 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <049FA0234069D945B133B9B4FB64C7750166D5B9@cadu1fp1.corp.emc.com>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mxic2.corp.emc.com ([128.221.31.40])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1917cn-00080v-00
	for <nfs@lists.sourceforge.net>; Thu, 03 Apr 2003 08:31:37 -0800
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Since we are now outside of NFSv4, and into application level distribution,
I will throw in a few thoughts.

There are 3 major 'handles' that you can grab to move data; Files, Blocks,
and Tracks.  Each of these has there limitations, and idiosyncrasies, so yes
integrating with apps is difficult.  Running an agent and moving things
around via files is by far the most intuitive, I have had experience with
OnCourse doing this and it has proven stable.  The big issue is how to find
the files in the first place, when to 'expire them' and such.  Where as
rules can be written to handle this, I am a bit to faint of heart to do so.

On the block level we all know snap-mirror or Celerra Replicator, and the
associated freeze/thaw methods used.  The trouble with block level
replication is, who is allowed to apply the changes, and how do the apps get
to know about it?  Since we are fortunate enough to not suffer a life of
windowze, we are in pretty good shape.  But....  If we move to v4 and start
down the road of client side caching, how do we know when the server shall
mark the clients mem map dirty?  What tolerances are there for
inconsistencies, and do we care if it is just a read or do we check a finger
print every time....

Then comes the track level, think of raid 1 +1.  That is a mirror of a
mirror that one can move all about.  Now we get into even more trouble, as
we have a replica, but how does the server handle the swap off of the older
replica (assuming this is in a running state) to a newer one.   Or worse yet
we only have a singe destination replica, so we either break rule #1 (never
allow 2 hosts to use the same partition at the same time) and make a
messaging interface, or we go through a freeze/thaw cycle again and flush
the mem map of the server mounting it.  Even after all this is done, your
still back in the world of notifying your clients.

My $.02 is not to put replication/caching in the protocol, but to have some
'intelligent' rules based system that can act as a
push/pull/replicate/stale/redirect/refresh service, that can be tailored to
cope with the oddities that each application will be presenting.  Failing
that the next smoothest thing is to do the third mirror, as the development
of such an interface to do the meta-data passing could prove extremely
interesting, multiple r/w clients on a single data source.... (MPFS does
this if your i/o size is large enough)

Hope this has provoked some thoughts.

Per


Date: Tue, 01 Apr 2003 21:56:05 +0100
From: James Pearson <james-p@moving-picture.com>
To: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
CC:  nfs@lists.sourceforge.net
Subject: Re: [NFS] NFSv4 and client caching to local disk?

We already do some distribution of large 'static' files to clients - but 
we don't have full control of the 3rd party applications we run as to 
where they look for their data - therefore it would be 'nice' to have 
the option of allowing the OS to do this for us ...

James Pearson

Bogdan Costescu wrote:
> On Mon, 31 Mar 2003, Jake Gold wrote:
> 
> 
>>I have a FAS940 with a cluster of Linux machines mounting _read-only_
>>volumes over NFSv3. My situation is the same as James Pearson's....those
>>machines read large, rarely modified files, where memory caching doesn't
>>help a whole lot. It would be very nice to be able to have my
>>under-worked local disks take some of the load off the filer.
> 
> 
> How about doing it in the application itself ? Often application has more 
> knowledge about what it needs than the OS. So in a case like the one that 
> you described I would copy the rarely modified file(s) to the local disk 
> and just before accessing them in any way check to see if they were 
> modified. If this is true read-only you don't even need to check this, but

> otherwise you could use some rsync-style transfer to get only the parts 
> that were modified (assuming that new data is not completely different)...

> Modification can be detected from the file attributes, md5sum or something

> else.
> 
> The application level caching is more interesting when the cache size is 
> smaller than the data set. The OS would typically use LRU strategy to 
> make some more room in the cache when needed, but this is not always the 
> best approach - the application is the only one that can have some more 
> information about what data will be needed in the near future.
> 





-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
