From: Brian Tinsley <btinsley@emageon.com>
Subject: Re: Re: broken umount -f
Date: Tue, 14 Jan 2003 13:32:44 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E2465DC.8000706@emageon.com>
References: <6440EA1A6AA1D5118C6900902745938E07D551E8@black.eng.netapp.com> <20030114170755.GA18952@questra.com> <shs8yxn5z6m.fsf@charged.uio.no> <20030114191953.GJ26872@questra.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [63.162.183.250] (helo=emgw2ksrv001.emgdom001.emageon.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18YWns-0003Zi-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Jan 2003 11:32:53 -0800
To: Scott Mcdermott <smcdermott@questra.com>
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

Scott Mcdermott wrote:

>Trond Myklebust on Tue 14/01 20:06 +0100:
>  
>
>>Linux will not allow you to unmount without killing those processes,
>>and I'd be opposed to any patch that tries to kill active processes
>>from within the filesystem.  This is something that needs to be
>>resolved in userland.
>>    
>>
>
>Last I checked, the programs wouldn't die even with -KILL when they were
>stuck in device-wait state.  The only way to reboot a machine with such
>processes is to reboot -f, which is wrong.  The filesystems should be
>able to have forced umount at sysadmin's discretion.
>  
>
I've had luck with:

kill -9 <pids>
umount -f <nfs_dirs>
kill -9 <pids>
umount -f <nfs_dirs>

The last umount always works for me.


-- 

Brian Tinsley
Chief Systems Engineer
Emageon






-------------------------------------------------------
This SF.NET email is sponsored by: Take your first step towards giving 
your online business a competitive advantage. Test-drive a Thawte SSL 
certificate - our easy online guide will show you how. Click here to get 
started: http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0027en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
