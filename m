From: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
Subject: ps -aux hangs on [nfsd]
Date: Fri, 07 Jan 2005 12:05:29 +0100
Message-ID: <41DE6CF9.6030100@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CmrwP-0001UF-0h
	for nfs@lists.sourceforge.net; Fri, 07 Jan 2005 03:06:01 -0800
Received: from acheron.informatik.uni-muenchen.de ([129.187.214.135])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CmrwN-0001zi-6R
	for nfs@lists.sourceforge.net; Fri, 07 Jan 2005 03:06:00 -0800
Received: from internaldeliver.acheron.informatik.uni-muenchen.de (localhost [127.0.0.1])
	by acheron.informatik.uni-muenchen.de (Postfix) with ESMTP id B0621435E0
	for <nfs@lists.sourceforge.net>; Fri,  7 Jan 2005 12:05:30 +0100 (CET)
Received: from [141.84.1.141] (galois.bio.ifi.lmu.de [141.84.1.141])
	(using TLSv1 with cipher RC4-MD5 (128/128 bits))
	(No client certificate requested)
	by acheron.informatik.uni-muenchen.de (Postfix) with ESMTP id A0750435C6
	for <nfs@lists.sourceforge.net>; Fri,  7 Jan 2005 12:05:30 +0100 (CET)
To: NFS NFS <nfs@lists.sourceforge.net>
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

Hi,

I've encountered a very very strange "bug" on one of our nfs servers.
It runs SuSE 9.0 with kernel 2.6.9 and exports some directories from
a 600GB IDE-Raid to about 60 clients with

/mnt/extraid1/extproj           @intern(rw,root_squash,sync)
/mnt/extraid1/extstorage        @intern(rw,root_squash,sync)

The clients run the same kernel and mount with

turing:/mnt/extraid1/extproj		/mnt/extraid1/extproj		nfs
   defaults,tcp,rw,hard,rsize=16384,wsize=16384 0 0
turing:/mnt/extraid1/extstorage         /mnt/extraid1/extstorage        nfs
   defaults,tcp,rw,hard,rsize=16384,wsize=16384 0 0

This is the same for all our nfs servers and clients, so this server
is special.

Everything works fine when starting the nfsserver and mounting the
directories. However, after about 1-2 weeks of normal works, some
things start to hang on the host, suddenly "ps -aux" hangs on showing
the [nfsd] processes. We recognize that because we do some

/etc/init.d/tomcat5 status >& /dev/null || /etc/init.d/rctomcat5 restart

via cron to check if the tomcat server is still running,
and the /etc/init.d/tomcat5 script uses "ps -aux".

So, when executing ps -aux the output shows the normal processes for
root, system users etc., then it comes to nfsd and shows

...
mysql    17132  0.0  0.0 481632 1248 ?       S    Jan03   0:00 /usr/sbin/mysqld-max
root     17166  0.0  0.0     0    0 ?        SW   Jan03   0:00 [nfsd]
root     17149  0.0  0.0     0    0 ?        SW   Jan03   0:00 [nfsd]
root     17150  0.0  0.0     0    0 ?        SW   Jan03   0:00 [nfsd]
root     17151  0.0  0.0     0    0 ?        SW   Jan03   0:00 [nfsd]
root     17152  0.0  0.0     0    0 ?        SW   Jan03   0:00 [nfsd]
root     17153  0.0  0.0     0    0 ?        SW   Jan03   0:00 [nfsd]
root     17154  0.0  0.0     0    0 ?        SW   Jan03   0:00 [nfsd]
root     17155  0.0  0.0     0    0 ?        SW   Jan03   0:00 [nfsd]
root     17156  0.0  0.0     0    0 ?        SW   Jan03   0:00 [nfsd]
root     17157  0.0  0.0     0    0 ?        SW   Jan03   0:00 [nfsd]
root     17165  0.0  0.0     0    0 ?        SW   Jan03   0:00 [nfsd]


and hangs. When I call top and sort for memory usage, I see that ps
is taking more and more memory. I killed it when using 1GB of memory.
We are running the nfsserver with 18 threads, so just the first 11
are shown.

However, when I call just "ps -x", I get all 18 [nfsd] threads:

...
17084 ?        S      0:00 /bin/sh /usr/bin/mysqld_safe ...
17166 ?        SW     0:00 [nfsd]
17149 ?        SW     0:00 [nfsd]
17150 ?        SW     0:00 [nfsd]
17151 ?        SW     0:00 [nfsd]
17152 ?        SW     0:00 [nfsd]
17153 ?        SW     0:00 [nfsd]
17154 ?        SW     0:00 [nfsd]
17155 ?        SW     0:00 [nfsd]
17156 ?        SW     0:00 [nfsd]
17157 ?        SW     0:00 [nfsd]
17165 ?        SW     0:00 [nfsd]
17164 ?        SW     0:00 [nfsd]
17163 ?        SW     0:00 [nfsd]
17162 ?        SW     0:00 [nfsd]
17161 ?        SW     0:00 [nfsd]
17160 ?        SW     0:00 [nfsd]
17159 ?        SW     0:00 [nfsd]
17158 ?        SW     0:00 [nfsd]
17169 ?        S      0:12 /usr/sbin/rpc.mountd -p 700
...


After calling "/etc/init.d/nfsserver restart", ps -aux works again, showing
all processes.

When ps -aux hung, the nfsserver still seemed to work fine, I could access
the filessystem from the nfs clients. In the log files, I did not find any
message about nfs errors or sth. similar.

The only thing that makes this nfs server special compared to the other
servers: It is outside our firewall and mounts one filesystem from
behind the firewall with a ssh tunnel. For that, it has some fstab line
   localhost:/export/rpm  /rpm-export  nfs
     defaults,tcp,ro,hard,rsize=16384,wsize=16384,port=701,mountport=702 0 0
It shouldn't affect the nfs server I guess, but who knows...

Any idea what that could be? How can ps -aux hang on showing a nfsd
thread and leaking memory up to over one GB? What can I do to provide
more helpful information? Turn one some debug options etc.?
Unfortunately, I cannot yet reprocude the behaviour reliably. It just shows
up some time, so far after about 1-2 weeks...

cu,
Frank


-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049
* Rekursion kann man erst verstehen, wenn man Rekursion verstanden hat. *




-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
