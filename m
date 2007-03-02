From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH 06/11] nfs-utils: mount:  AUTH_NONE mounts
Date: Fri, 02 Mar 2007 10:27:54 -0500
Message-ID: <45E8427A.3030806@redhat.com>
References: <45E2C1FD.7000506@RedHat.com>	<17891.52293.103984.465480@notabene.brown>	<45E43C92.6090805@redhat.com>	<17894.2913.850879.838771@notabene.brown>	<45E6FB0B.7000204@redhat.com>
	<17895.41362.382320.934994@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HN9fy-0002dd-6u
	for nfs@lists.sourceforge.net; Fri, 02 Mar 2007 07:28:06 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HN9fz-0004EB-2R
	for nfs@lists.sourceforge.net; Fri, 02 Mar 2007 07:28:08 -0800
In-Reply-To: <17895.41362.382320.934994@notabene.brown>
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

Neil Brown wrote:
> On Thursday March 1, staubach@redhat.com wrote:
>   
>> This was used to address RH bz187370.
>>     
>
> Thanks for the link.  It provides good context.
>
> I would have thought the appropriate response would have been the
> following patch, and a suggestion to use
>   mount -o sec=none .....
> to mount the filesystem.
> Do you see a problem with that?

Yes, that's not sufficient.  The client should be able to automatically
"do the right thing".  The systems administrator shouldn't have to
specify the authentication flavor to match the server flavor.  That
systems administrator should only have to specify when there are
specific requirements for that client.

With this change, autofs would not be able correctly handle mounting
this server via /net.  It should be able to, especially since the
server will accept _any_ flavor coming from the client.

And a question, I thought that I looked, and it did not appear that
the kernel supported AUTH_NONE on the client side.  Did I miss it?

    Thanx...

       ps

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
