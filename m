From: Skottie Miller <skottie@anim.dreamworks.com>
Subject: Re: NFSv4 and client caching to local disk?
Date: Tue, 01 Apr 2003 11:56:56 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E89EF08.2050401@anim.dreamworks.com>
References: <Pine.LNX.4.44.0304012046510.5929-100000@kenzo.iwr.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jake Gold <jake@dtiserv2.com>, James Pearson <james-p@moving-picture.com>,
   Charles.Lever@netapp.com, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from garm.dreamworks.com ([64.173.252.34] helo=postal.anim.dreamworks.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 190RtA-0003DN-00
	for <nfs@lists.sourceforge.net>; Tue, 01 Apr 2003 11:57:44 -0800
To: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
In-Reply-To: <Pine.LNX.4.44.0304012046510.5929-100000@kenzo.iwr.uni-heidelberg.de>
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

Bogdan Costescu wrote:
> On Mon, 31 Mar 2003, Jake Gold wrote:
> 
>>I have a FAS940 with a cluster of Linux machines mounting _read-only_
>>volumes over NFSv3. My situation is the same as James Pearson's....those
>>machines read large, rarely modified files, where memory caching doesn't
>>help a whole lot. It would be very nice to be able to have my
>>under-worked local disks take some of the load off the filer.
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

We do the caching to compute-node local disk, via the applications when we can.
But two things often make that difficult:  (1) the working set of the cached data
is larger than the compute-note local disk, and (2) we don't own all the applications.

So, I complement the compute-node local disk caches (and sometimes replace them)
with a series of NetCache c2100 dNFS boxes.  The origin data is on 960's,
which serve up their data to the user workstations, and to the caches.
The renderfarm compute nodes get almost all their high-traffic read-only
data off the caches.  This maintains good interactive performance for the
user workstations and keeps the renderfarm fed.

 -skottie


-- 

Scott Miller                 | Animation Technology
work: skottie@dreamworks.com | Dreamworks Feature Animation
life: skottie@pobox.com



-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
