From: James Pearson <james-p@moving-picture.com>
Subject: Re: NFSv4 and client caching to local disk?
Date: Tue, 01 Apr 2003 21:56:05 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E89FCE5.8060106@moving-picture.com>
References: <Pine.LNX.4.44.0304012046510.5929-100000@kenzo.iwr.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from gadolinium.btinternet.com ([194.73.73.111])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 190SoA-0003Vv-00
	for <nfs@lists.sourceforge.net>; Tue, 01 Apr 2003 12:56:38 -0800
To: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
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
