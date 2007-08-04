From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 01/10] mount.nfs: Support double-wide characters
 in printed strings
Date: Fri, 03 Aug 2007 20:04:32 -0400
Message-ID: <46B3C290.80000@oracle.com>
References: <20070803172329.3357.47604.stgit@monet.1015granger.net>
	<18099.41763.912573.736088@notabene.brown>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------040300040601010106000104"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IH79s-0002EK-Rj
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 17:06:17 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IH79v-0005qQ-JW
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 17:06:20 -0700
In-Reply-To: <18099.41763.912573.736088@notabene.brown>
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
--------------040300040601010106000104
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Neil Brown wrote:
> On Friday August 3, chuck.lever@oracle.com wrote:
>> Previous NLS changes missed a spot or two.  This patch tries to get
>> most of them, but probably misses a few more.
>>
>> In errors.c:mount_errors() I've removed a period at the end of the error
>> messages; this is consistent with other error messages I've examined.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ....
>> --- a/utils/mount/nfs4mount.c
>> +++ b/utils/mount/nfs4mount.c
>> @@ -321,8 +321,8 @@ int nfs4mount(const char *spec, const char *node, int flags,
>>  			else if (!strcmp(opt, "sharecache"))
>>  				unshared = !val;
>>  			else if (!sloppy) {
>> -				printf(_("unknown nfs mount option: "
>> -					 "%s%s\n"), val ? "" : "no", opt);
>> +				printf(_("unknown nfs mount option: %s%s\n"),
>> +						val ? "" : _("no"), opt);
>>  				goto fail;
> 
> I removed the _() around the "no".  Translating the 'no' without
> translating the option doesn't make any sense to me.
> You would run
>   mount -o nocoffee .....
> and get an error
>    Option inconnue de mount du nfs: noncoffee
> 
> (or something - my French non-existent, I just played with
> google-translate).  Which is wrong.  'noncoffee' isn't the bad
> option.  'nocoffee' is.

OK.

>> --- a/utils/mount/nfsumount.c
>> +++ b/utils/mount/nfsumount.c
>> @@ -67,7 +67,7 @@ static int del_mtab(const char *spec, const char *node)
>>                  res = umount2 (node, MNT_FORCE);
>>                  if (res == -1) {
>>                          int errsv = errno;
>> -                        perror("umount2");
>> +                        perror(_("umount2"));
>>                          errno = errsv;
>>                          if (errno == ENOSYS) {
>>                                  if (verbose)
>> @@ -93,7 +93,7 @@ static int del_mtab(const char *spec, const char *node)
>>                                  update_mtab(node, &remnt);
>>                          return 0;
>>                  } else if (errno != EBUSY) {    /* hmm ... */
>> -                        perror("remount");
>> +                        perror(_("remount"));
>>                          nfs_error(_("%s: could not remount %s read-only"),
>>                                  	progname, spec);
>>                  }
> 
> And I'm not at all convinced about the _() in perror - In the first
> case it is a syscall name.  How would you translate that?  The second
> is possibly less doubtful, but it would probably be best to discard
> the perror calls and pass strerror(errno) to nfs_error with an
> appropriate format - What do you think?

Adding _() for perror is consistent with the other perror calls already 
in the code.  I suppose if those are objectionable, you should remove 
them all.

--------------040300040601010106000104
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
email;internet:chuck dot lever at nospam oracle dot com
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------040300040601010106000104
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------040300040601010106000104
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------040300040601010106000104--
