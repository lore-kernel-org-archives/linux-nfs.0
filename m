From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH 06/11] nfs-utils: mount:  AUTH_NONE mounts
Date: Tue, 13 Mar 2007 12:13:25 -0400
Message-ID: <45F6CDA5.9020607@redhat.com>
References: <45E2C1FD.7000506@RedHat.com>	<17891.52293.103984.465480@notabene.brown>	<45E43C92.6090805@redhat.com>	<17894.2913.850879.838771@notabene.brown>	<45E6FB0B.7000204@redhat.com>	<17895.41362.382320.934994@notabene.brown>	<45E8427A.3030806@redhat.com>
	<17910.15196.104675.695016@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HR9cz-0007lk-8i
	for nfs@lists.sourceforge.net; Tue, 13 Mar 2007 09:13:33 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HR9d1-0005Tf-34
	for nfs@lists.sourceforge.net; Tue, 13 Mar 2007 09:13:35 -0700
In-Reply-To: <17910.15196.104675.695016@notabene.brown>
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
> On Friday March 2, staubach@redhat.com wrote:
>   
>> Neil Brown wrote:
>>     
>>> On Thursday March 1, staubach@redhat.com wrote:
>>>   
>>>       
>>>> This was used to address RH bz187370.
>>>>     
>>>>         
>>> Thanks for the link.  It provides good context.
>>>
>>> I would have thought the appropriate response would have been the
>>> following patch, and a suggestion to use
>>>   mount -o sec=none .....
>>> to mount the filesystem.
>>> Do you see a problem with that?
>>>       
>> Yes, that's not sufficient.  The client should be able to automatically
>> "do the right thing".  The systems administrator shouldn't have to
>> specify the authentication flavor to match the server flavor.  That
>> systems administrator should only have to specify when there are
>> specific requirements for that client.
>>     
>
> Ok..... so maybe we want "-o sec=" to accept a list of flavours, with
> the default being "-o sec=sys:none".  Would that be suitable?
> We would pick the first one in the server's list that is also in the
> clients list.
> I'm not sure allowing a list to be specified is really needed, so the
> following patch just causes the default to be effectively
> sec=sys:none.
> Would that suit?
>
> I just really don't like the idea of sending NFS requests with
> AUTH_SYS when mountd has said that it only supports AUTH_NONE.
>
>   

I have to admit that aesthetically, sending AUTH_SYS requests instead
of AUTH_NONE seems inelegant, but it works and matches the behavior of
other implementations.
>> And a question, I thought that I looked, and it did not appear that
>> the kernel supported AUTH_NONE on the client side.  Did I miss it?
>>     
>
> Well....
> fs/nfs/super.c:nfs_pseudoflavour_to_name certainly recognises RPC_AUTH_NULL.
> and net/sunrpc/auth.c:auth_flavors has authnull_ops.
> So I suspect the kernel supports it.  I admit I haven't tried.

With a small update to the patch, the kernel seems to _almost_ generate
AUTH_NONE requests.  Interestingly, the kernel makes the first FSINFO
call with AUTH_SYS and then makes another FSINFO call with AUTH_NONE.
Both FSINFO calls suceeded and returned the same information.

The small update to the patch is to add the line:

    data.flags |= NFS_MOUNT_SECFLAVOUR;

after setting data.pseudoflavor to flavor[i].

Anyone know why, off hand, the NFS client needs to make two FSINFO calls?

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
