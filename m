From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] NFS: Zeroing NFS and kNFSD stats
Date: Tue, 13 Jul 2004 11:08:08 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40F3FAD8.7090707@RedHat.com>
References: <40F3D483.8020507@RedHat.com> <20040713143044.GA3023@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BkOtA-0000yr-M1
	for nfs@lists.sourceforge.net; Tue, 13 Jul 2004 08:08:12 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1BkOt9-0005OV-RW
	for nfs@lists.sourceforge.net; Tue, 13 Jul 2004 08:08:12 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20040713143044.GA3023@fieldses.org>
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

J. Bruce Fields wrote:

>On Tue, Jul 13, 2004 at 08:24:35AM -0400, Steve Dickson wrote:
>  
>
>>Here is a patch I've been using for quite a while now
>>that will zero out the nfs stats on both the server
>>and client side.
>>    
>>
>
>What is it useful for?
>  
>
A few things... One to see if how traffic is flowing... sure you can 
look a the numbers go
up but to be able to start from zero gives you a better idea on how well 
things are flowing.
I also use it for testing patchs that deal with caching or  RPC changes 
to see what impact
they have on OTW traffic...  Another use it to see what opts are really 
being tested... Starting
up a test run, zeroing out the stats give you a very clear picture of 
what exactly is going on...
There probably a few more uses that are just not coming to me right 
now... Its one of those
tools that I keep finding ways to use... :)

SteveD.




-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
