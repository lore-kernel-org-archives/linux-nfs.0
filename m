From: Roger Heflin <rheflin@atipa.com>
Subject: Re: Apparent Deadlock with nfsd/jfs on 2.6.21.1 under bonnie.
Date: Tue, 15 May 2007 17:06:38 -0500
Message-ID: <464A2EEE.7070509@atipa.com>
References: <4649BED9.6090207@atipa.com>
	<pan.2007.05.15.22.03.07.359081@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ho5AF-0003AM-HE
	for nfs@lists.sourceforge.net; Tue, 15 May 2007 15:06:40 -0700
Received: from 125.14.124.24.cm.sunflower.com ([24.124.14.125]
	helo=mail.atipa.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Ho5AF-00063e-VK
	for nfs@lists.sourceforge.net; Tue, 15 May 2007 15:06:42 -0700
In-Reply-To: <pan.2007.05.15.22.03.07.359081@linux.vnet.ibm.com>
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

Dave Kleikamp wrote:
> Sorry if I'm missing anyone on the reply, but my mail feed is messed up
> and I'm replying from the gmane archive.
> 
> On Tue, 15 May 2007 09:08:25 -0500, Roger Heflin wrote:
> 
>> Hello,
>>
>> Running 2.6.21.1 (FC6 Dist), with a RHEL client (client
>> appears to not be having issues) I am getting what I believe
>> is a deadlock on the server end.    This is with JFS and
>> NFSD, I have not tested yet with a non-JFS filesystem,
>> though our customer indicated that they have duplicated it with
>> the ext3 filesystem.
> 
> I don't have an answer to an ext3 deadlock, but this looks like a jfs
> problem that was recently fixed in linux-2.6.22-rc1.  I had intended to
> send it to the stable kernel after it was picked up in mainline, but
> hadn't gotten to it yet.
> 
> The patch is here:
> http://git.kernel.org/gitweb.cgi?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=05ec9e26be1f668ccba4ca54d9a4966c6208c611
> 

Ok.

My customer reported that he though he had a ext3, so far I have
not been able to duplicate the ext3 hang.

If ext3 survives until tomorrow, I will retest unpatched jfs, and then
patch it and test again.


>> The basic setup is:
>> fiber channel array -> qlogic fiber card -> /dev/sdx -> LVM stripe ->
>> jfs -> nfs.
>>
>> Running bonnie on a NFS share has apparently produced a deadlock.   I
>> have ran bonnie several times without having any issues, I don't believe
>> this is a HW issue, we have a couple of other machines configured with
>> slightly different HW and are also able to duplicate this problem on
>> those machines.  There are no abnormal messages in dmesg or in the
>> messages file.
>>
>> After having the apparent deadlock I started a dd of a on the deadlocked
>> filesystem and according to vmstat 1 that was actually working, I then
>> did a "mkdir junk" on the deadlocked filesystem and that apparently put
>> the cat into a permanent "D" state.   I will include the sysrq -t from
>> before the cat/mkdir and after the cat/mkdir.
>>
>> I believe I can duplicate this again, and other than the processes going
>> into the "D" state everything else seems to work.   Other filesytems
>> appear to be functional, I can still login to the machine.
>>
>> Right now the machine is in the deadlocked state, and I will wait for
>> any suggestions of more data to collect or other tests to try.
> 
> I haven't tried it on a locked-up system, but you may try waking up the
> [jfsIO] kernel thread with a signal.  I'm not sure what signals may get
> through, since the thread doesn't specifically act on a signal.
> 

I will try on the next lockup.

                    Roger

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
