From: "Jeffrey S. Mulliken" <mulliken@v-stor.com>
Subject: Re: Help with NFS and automount
Date: Tue, 19 Mar 2002 13:07:19 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3C97A887.4030008@v-stor.com>
References: <3C92F719.2070507@v-stor.com> <3C971421.C82EFC6@lipsyncpost.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Received: from [64.160.42.140] (helo=mail.v-stor.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16nQpT-0000cL-00
	for <nfs@lists.sourceforge.net>; Tue, 19 Mar 2002 13:07:35 -0800
To: Simon Burley <simonb@lipsyncpost.co.uk>, nfs@lists.sourceforge.net
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>




Simon Burley wrote:

>"Jeffrey S. Mulliken" wrote:
>
>>Dear Brainiacs,
>>
>>    I am having a problem and have come to the end of what I can think
>>of to try.
>>
>
><snip>
>
>>    PROBLEM:
>>    Client machine IPL's without any problems.  All of the machines in
>>the host network are accessible via ftp or telnet.
>>    Several nfs mounts are mounted via the /etc/fstab, and mount without
>>problems, and are useable
>>    A particular nfs mount point gets mounted by the automounter
>>successfully via a file /etc/auto.ccwork.  No problems there.
>>    However, trying to access the same machine as above using the
>>program /etc/auto.net, results in "No such file or directory".
>>    No errors in /var/log/messages, nor in /var/adm/messages on the
>>Solaris host.  I will attach the pertinent files.
>>
>>    Any suggestions with be greatly appreciated.
>>
>
>Does /etc/auto.net have the executable bit set?
>Does typing /etc/auto.net <hostname> return anything?, eg.
>
>-fstype=nfs,hard,intr,nodev,nosuid,rsize=8192,wsize=8192 \
>	/local marge:/local
>
>S.
>
Simon,

    Thanks for the reply.  Yes, /etc/auto.net is executable, and if I 
run the auto.net program as
you suggest it returns the following:

==============================================
[hostname: ] /etc/auto.net dev3
-fstype=nfs,hard,intr,nodev,nosuid \
        /ccStore16 dev3:/ccStore16 \
        /ccStore19 dev3:/ccStore19 \
        /ccStore20 dev3:/ccStore20 \
        /ccStore21 dev3:/ccStore21 \
        /ccStore22 dev3:/ccStore22 \
        /export/home dev3:/export/home
==============================================

But, for some reason, when I try to mount it, I get:

=====================================
[hostnames]# cd /net/dev3
bash: cd: /net/dev3: No such file or directory
=====================================

.....and as I was writing this, I gave it another try, and it's 
resolved. I don't know for sure what
the original problem was, but the machine was originally a RH 6.2 
machine, and I had done
an upgrade to 7.2.  Well, I backed up a couple of files, and did a full 
install, starting with
formatting the partitions.  After the cold install, and 
re-configuration, it now works.  Thanks
to all for any and all head scratching along with me.  

    Cheers....  
   
        Jeff.


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
