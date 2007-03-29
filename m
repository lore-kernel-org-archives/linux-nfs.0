From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: fsid question
Date: Thu, 29 Mar 2007 10:23:46 -0400
Message-ID: <460BCBF2.20003@redhat.com>
References: <46082D10.1060301@cse.yorku.ca>	<46083474.8090906@redhat.com>
	<20070329155457.458bf8a9@slopi>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chris Osicki <osk@admin.swisscom-mobile.ch>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HWvr3-0006Bd-CM
	for nfs@lists.sourceforge.net; Thu, 29 Mar 2007 07:43:58 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HWvr5-0005uA-Gk
	for nfs@lists.sourceforge.net; Thu, 29 Mar 2007 07:43:59 -0700
In-Reply-To: <20070329155457.458bf8a9@slopi>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Chris Osicki wrote:
> On Mon, 26 Mar 2007 17:00:36 -0400
> Wendy Cheng <wcheng@redhat.com> wrote:
>
> Hi
>
>   
>> Jason Keltz wrote:
>>     
>>> Hi.
>>>
>>> I'm running a RedHat Enterprise 4 system.
>>>
>>> I have a question about the fsid option in /etc/exports that I was 
>>> hoping someone might be able to help with.
>>>
>>> I am working with LVM under Linux.  If I export LVM volumes via NFS, the 
>>> fsid is based on major/minor number.  
>>>       
>> This statement needs correction. An NFS fsid is not based on major/minor 
>> numbers - it is is a 32 bit number that admin (root) can arbitrary 
>> choose and use to uniquely identify an NFS export. More on this in the 
>> following comment.
>>     
>
> And this statement needs correction too ;-)
> fsid _is_ based on major/minor number. I learned it the hard way,
> seeing two filesystem swapped on NFS clients because of minor
> number change after switching a cluster package to another node.
>
> Then I read carefully fsid section in man 5 exports.
>
>   
Well, I still don't see anywhere there is a documented definition that 
says "(NFS) fsid _is_ based on major/minor number". The man page 
describes it as "the filesystem identification portion of the file 
handle and file attributes used on the wire". My opinion is that an NFS 
"fsid" is the number you specify in the export file - nothing more.

On the other hand, arguments like these are kind of silly. The important 
thing is to advocate and make sure people know how to use "fsid" in a 
clustered environment.

-- Wendy


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
