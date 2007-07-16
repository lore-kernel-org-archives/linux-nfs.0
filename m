From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 03/17] mount.nfs: Remove support for "-t" option
Date: Sun, 15 Jul 2007 23:44:37 -0400
Message-ID: <469AE9A5.3000107@oracle.com>
References: <20070716031503.11209.67390.stgit@manray.1015granger.net>
	<18074.59398.729707.566494@notabene.brown>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------040207010204090007070808"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IAHWy-0004wa-9S
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:45:52 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IAHX0-0007uJ-O3
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:45:56 -0700
In-Reply-To: <18074.59398.729707.566494@notabene.brown>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a multi-part message in MIME format.
--------------040207010204090007070808
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Neil Brown wrote:
> On Sunday July 15, chuck.lever@oracle.com wrote:
>> /bin/mount will never pass "-t" to a mount helper, since it passes the
>> fs-type in the name of the program it is executing.
> 
> Does it hurt to leave it there though?  Maybe it makes unit-testing
> easier?
> Or maybe not....

Well, part of these changes remove stuff that just seems confusing to 
anyone trying to understand the code, and yes, this one is quite 
optional.  Honestly, I couldn't think of a case where this could 
possibly be useful, but I'm open to education.

The fact that we can do a "mount.nfs -t nfs4" and that's the same as 
"mount.nfs4" seems a little weird.  The mount command will parse the 
"-t" option and invoke either "mount.nfs" or "mount.nfs4"... extra logic 
here is just going to cloud things.

>> @@ -413,23 +413,12 @@ int main(int argc, char *argv[])
>>  	mount_point = argv[2];
>>  
>>  	argv[2] = argv[0]; /* so that getopt error messages are correct */
>> -	while ((c = getopt_long (argc - 2, argv + 2, "rt:vVwfno:hs",
>> +	while ((c = getopt_long (argc - 2, argv + 2, "r:vVwfno:hs",
>                                                       ^^
> 
> Ooops.  -r takes an argument now?

Hmmm.  I'll fix that too.

>>  		if ((mc = getfsfile(mount_point)) == NULL ||
>> -		    strcmp(mc->m.mnt_fsname, spec) != 0 ||
>> -		    strcmp(mc->m.mnt_type, (nfs_mount_vers == 4 ? "nfs4":"nfs")) != 0
>> -		    ) {
>> -			fprintf(stderr, "%s: permission died - no match for fstab\n",
>> -				progname);
>> +		    !strcmp(mc->m.mnt_fsname, spec) ||
>                    ^^^^
> 
> I absolutely LOATHE that construct. The first thing you read is "!"
> which means "not" but it is actually a test for "are these things
> equal" which makes it confusing (to me).  So I always like to see the
> result of strcmp tested with "== 0"  "< 0"  "> 0"  as the relation
> given applies exactly to the tested relation between the strings.

OK, now that I know that's the preference, I will use "== 0".

> Further:
>> -		    strcmp(mc->m.mnt_fsname, spec) != 0 ||
> and
>> +		    !strcmp(mc->m.mnt_fsname, spec) ||
> 
> are opposite tests, and it is not clear to me why you inverted the
> test.

Simple explanation: because I'm a bone-head.

--------------040207010204090007070808
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
url:http://oss.oracle.com/~cel
version:2.1
end:vcard


--------------040207010204090007070808
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------040207010204090007070808
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------040207010204090007070808--
