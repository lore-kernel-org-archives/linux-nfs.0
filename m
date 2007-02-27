From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH 06/11] nfs-utils: mount:  AUTH_NONE mounts
Date: Tue, 27 Feb 2007 09:13:38 -0500
Message-ID: <45E43C92.6090805@redhat.com>
References: <45E2C1FD.7000506@RedHat.com>
	<17891.52293.103984.465480@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HM35O-00021p-VS
	for nfs@lists.sourceforge.net; Tue, 27 Feb 2007 06:13:48 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HM35O-000535-8U
	for nfs@lists.sourceforge.net; Tue, 27 Feb 2007 06:13:48 -0800
In-Reply-To: <17891.52293.103984.465480@notabene.brown>
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
> On Monday February 26, SteveD@redhat.com wrote:
>   
>> commit 0ffd74c990aca3761b79316d47e1b1778273681c
>> Author: Steve Dickson <steved@redhat.com>
>> Date:   Sat Feb 24 15:27:46 2007 -0500
>>
>>     Added support to specify the AUTH_NONE security flavor (i.e. -o sec=none)
>>     
>
> If you specify "-o sec=none" then data.pseudoflavor will == AUTH_NONE,
> but
>
>   

This support is being added so that the client can mount a file system
which was exported with sec=none.

>>     
>>     Signed-off-by: Steve Dickson <steved@redhat.com>
>>
>> diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
>> index d437036..7759260 100644
>> --- a/utils/mount/nfsmount.c
>> +++ b/utils/mount/nfsmount.c
>> @@ -1093,12 +1093,14 @@ nfsmount(const char *spec, const char *node, int *flags,
>>  
>>  		flavor = mountres->auth_flavors.auth_flavors_val;
>>  		while (--i >= 0) {
>> -			if (flavor[i] == data.pseudoflavor)
>> -				yum = 1;
>>  #ifdef NFS_MOUNT_DEBUG
>> -			printf("auth flavor %d: %d\n",
>> -				i, flavor[i]);
>> +			printf("auth flavor[%d] %d\n", i, flavor[i]);
>>  #endif
>> +			if (flavor[i] == data.pseudoflavor ||
>> +				flavor[i] == AUTH_NONE) {
>> +				yum = 1;
>> +				break;
>> +			}
>>     
>
> You are testing if flavor[i] == AUTH_NONE, which doesn't make sense to
> me....

This loop is looking for AUTH_NONE in the list of authentication
flavors that the server supports and was returned through the MOUNT
protocol during mounting.

Basically, if the server file system is exported with AUTH_NONE, then
it doesn't matter what flavor that the client chooses, the server will
always map it to AUTH_NONE and all requests will be processed with the
anonymous uid and gid.

       ps

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
