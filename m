From: "jehan.procaccia" <jehan.procaccia@int-evry.fr>
Subject: Re: async vs. sync
Date: Mon, 22 Nov 2004 19:46:58 +0100
Message-ID: <41A23422.202@int-evry.fr>
References: <EXCHG2003BjbUf9Sp2W000071ca@EXCHG2003.microtech-ks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: 'Olaf Kirch' <okir@suse.de>, nfs@lists.sourceforge.net,
	trond.myklebust@fys.uio.no, mci-unix@int-evry.fr
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWJDV-0001zD-KF
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 10:47:13 -0800
Received: from smtp2.int-evry.fr ([157.159.10.45])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CWJDU-0006fj-D5
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 10:47:13 -0800
To: Roger Heflin <rheflin@atipa.com>
In-Reply-To: <EXCHG2003BjbUf9Sp2W000071ca@EXCHG2003.microtech-ks.com>
Sender: nfs-admin@lists.sourceforge.net
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

OK , thanks for the explanation . So now I try:

exports          mount
sync             async     -> Safe and fast

[root@arvouin ~]
$mount cobra3:/p2v5f1/ -o async /mnt/cobra3

unfortunatly the async mount option  doesn't shows up in /proc/mounts, 
so I am not sure my client is using async, how can I check that ?

[root@arvouin ~]
$cat /proc/mounts
cobra3:/p2v5f1/ /mnt/cobra3 nfs 
rw,v3,rsize=8192,wsize=8192,hard,tcp,lock,addr=cobra3 0 0

Anyway, I untar again my httpd, I'am late so I didn't wait 13 minute or 
so but it started to be as long as it was :-(

Now on the server I removed ACL (nerver asked for it though !?)
$ cat /proc/fs/nfs/exports | grep arvouin
/p2v5f1 arvouin.int-evry.fr(rw,no_root_squash,sync,wdelay,no_acl) # 
157.159.21.55
again I cannot check on the client that this option is removed  ?, 
anyway again I untar my httpd,  I'am still late ... but seeing each file 
(tar -v !) shouwing up every second or so in the tty tells me that it 
will take at least 10 minutes ... :-(

Any other idea ? what is wrong in my config ?

thanks.




Roger Heflin wrote:

>This might be the issue, (and someone correct this if I am incorrect), 
>I know I ran into it a couple of years ago, and it is not the easiest
>to understand exactly what is actually going on.
>
>There are 2 places where you can put sync and async, one is the exports
>and one is on the mount command.  They are different.
>
>You want sync on the exports, this will allow a client to survive without
>data loss if the server reboots.   You want async on the client mount end
>and
>this will generally give you the speed.   With async on the client end
>the client is keeping track of what is outstanding if the server crashes,
>so you won't lose data.  With async on both ends the server tells one that
>the data is safe when it is not, and if the server crashes the client things
>that the data was safe when it really was not.  
>
>If you put sync in both locations then your NFS disk is fully synced and 
>the application won't even start another write until the last one is
>confirmed
>finished and on the actual disk.   With async on the client end the next
>write 
>will start before the client has received an ack from the server, and this
>will
>be reasonably fast.
>
>So basically:
>
>exports          mount
>sync             sync      -> really safe and really slow
>sync             async     -> Safe and fast
>async            either    -> unsafe and fast.
>
>Running async exports and async mount did not appear (under my testing) to
>be faster under a sustained load than did sync exports and async mount.
>When
>the initial test was started async/async was faster but that quick changed
>once
>the buffer cache filled up.
>
>                       Roger
>
>
>  
>
>>-----Original Message-----
>>From: nfs-admin@lists.sourceforge.net 
>>[mailto:nfs-admin@lists.sourceforge.net] On Behalf Of jehan.procaccia
>>Sent: Monday, November 22, 2004 11:55 AM
>>To: Olaf Kirch
>>Cc: nfs@lists.sourceforge.net; trond.myklebust@fys.uio.no; 
>>mci-unix@int-evry.fr
>>Subject: Re: [NFS] async vs. sync
>>
>>Olaf Kirch wrote:
>>
>>    
>>
>>>On Tue, Nov 16, 2004 at 10:48:12AM -0800, Lever, Charles wrote:
>>> 
>>>
>>>      
>>>
>>>>i'm just looking for clarification so i can provide a good 
>>>>        
>>>>
>>explanation 
>>    
>>
>>>>in the Linux NFS FAQ about the evils of using "async."  i'll cruise 
>>>>through the server code.
>>>>   
>>>>
>>>>        
>>>>
>>>Just about the only reason for async I can think of is if 
>>>      
>>>
>>you have an 
>>    
>>
>>>incoming data stream you need to write at a constant rate 
>>>      
>>>
>>(think of a 
>>    
>>
>>>diskless set top box writing an mpeg2 stream)
>>>
>>>Olaf
>>> 
>>>
>>>      
>>>
>>OK, but using sync at my site is really really slow ... 
>>compare to async ! here's a detailed (options printed) 
>>demonstration for an untar operation that takes 13 minutes in 
>>async mode and only 14 secondes in sync mode !!
>>
>>1) Export in sync mode
>>NFS server  (RedHat ES3 kernel 2.4.21-4.ELsmp) options for 
>>that export:
>>$ cat /proc/fs/nfs/exports | grep arvouin
>>/p2v5f1 arvouin.int-evry.fr(rw,no_root_squash,sync,wdelay,acl) #
>>157.159.21.55
>>$ cat /var/lib/nfs/xtab  | grep arvouin
>>/p2v5f1
>>arvouin.int-evry.fr(rw,sync,wdelay,hide,nocrossmnt,secure,no_r
>>    
>>
>oot_squash,no_all_squash,subtree_check,secure_locks,acl,mapping=identity,ano
>nuid=-2,anongid=-2)
>  
>
>>Client running Fedora Core 2, kernel 2.6.8-1.521 
>>[root@arvouin /mnt/cobra3/mci/test/Test-sync] $cat /proc/mounts
>>cobra3:/p2v5f1 /mnt/cobra3 nfs
>>rw,v3,rsize=8192,wsize=8192,hard,tcp,lock,addr=cobra3 0 0 
>>$time tar xvfz /usr/src/redhat/SOURCES/httpd-2.0.51.tar.gz
>>real    13m3.686s
>>user    0m1.055s
>>sys     0m4.354s
>>
>>2) Export in async mode:
>>Same NFS server, options for that export:
>>$ cat /proc/fs/nfs/exports | grep arvouin
>>/p2v5f1 arvouin.int-evry.fr(rw,no_root_squash,async,wdelay,acl) #
>>157.159.21.55
>>$ cat /var/lib/nfs/xtab  | grep arvouin
>>/p2v5f2
>>arvouin.int-evry.fr(rw,async,wdelay,hide,nocrossmnt,secure,no_
>>    
>>
>root_squash,no_all_squash,subtree_check,secure_locks,acl,mapping=identity,an
>onuid=-2,anongid=-2)
>  
>
>>Same client running Fedora Core 2, kernel 2.6.8-1.521
>>cobra3:/p2v5f1 /mnt/cobra3 nfs
>>rw,v3,rsize=8192,wsize=8192,hard,tcp,lock,addr=cobra3 0 0 
>>[root@arvouin /mnt/cobra3/mci/test/Test-sync] $time tar xvfz 
>>/usr/src/redhat/SOURCES/httpd-2.0.51.tar.gz
>>real    0m14.802s
>>user    0m0.867s
>>sys     0m2.886s
>>
>>My users won't accept the sync performances ! . I have no 
>>choice, but is running in async mode is really evil as you 
>>mentioned it ? is there a way to have better performances in 
>>sync in my case ?  As anyone had the same gap in performance 
>>as me ( here 55 times longer in sync mode !)  ?
>>
>>Thanks.
>>
>>
>>-------------------------------------------------------
>>SF email is sponsored by - The IT Product Guide Read honest & 
>>candid reviews on hundreds of IT Products from real users.
>>Discover which products truly live up to the hype. Start reading now. 
>>http://productguide.itmanagersjournal.com/
>>_______________________________________________
>>NFS maillist  -  NFS@lists.sourceforge.net 
>>https://lists.sourceforge.net/lists/listinfo/nfs
>>
>>    
>>
>
>  
>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
