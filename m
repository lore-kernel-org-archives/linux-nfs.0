From: Simon Burley <simonb@lipsyncpost.co.uk>
Subject: Re: Help with NFS and automount
Date: Tue, 19 Mar 2002 10:34:09 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3C971421.C82EFC6@lipsyncpost.co.uk>
References: <3C92F719.2070507@v-stor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from adsl-217-154-22-227.mistral.co.uk ([217.154.22.227] helo=ntserver.lipsyncpost.co.uk)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16nGvX-000784-00
	for <nfs@lists.sourceforge.net>; Tue, 19 Mar 2002 02:33:11 -0800
To: "Jeffrey S. Mulliken" <mulliken@v-stor.com>
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

"Jeffrey S. Mulliken" wrote:
> 
> Dear Brainiacs,
> 
>     I am having a problem and have come to the end of what I can think
> of to try.

<snip>

>     PROBLEM:
>     Client machine IPL's without any problems.  All of the machines in
> the host network are accessible via ftp or telnet.
>     Several nfs mounts are mounted via the /etc/fstab, and mount without
> problems, and are useable
>     A particular nfs mount point gets mounted by the automounter
> successfully via a file /etc/auto.ccwork.  No problems there.
>     However, trying to access the same machine as above using the
> program /etc/auto.net, results in "No such file or directory".
>     No errors in /var/log/messages, nor in /var/adm/messages on the
> Solaris host.  I will attach the pertinent files.
> 
>     Any suggestions with be greatly appreciated.

Does /etc/auto.net have the executable bit set?
Does typing /etc/auto.net <hostname> return anything?, eg.

-fstype=nfs,hard,intr,nodev,nosuid,rsize=8192,wsize=8192 \
	/local marge:/local

S.
-- 
" READY. FIRE. AIM. "

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
