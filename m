From: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
Subject: very strange nfs errors with nfsroot
Date: Tue, 24 Aug 2004 17:14:02 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <412B5B3A.6070600@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bzczv-0002VZ-75
	for nfs@lists.sourceforge.net; Tue, 24 Aug 2004 08:14:07 -0700
Received: from acheron.informatik.uni-muenchen.de ([129.187.214.135])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1Bzczu-0001Az-Db
	for nfs@lists.sourceforge.net; Tue, 24 Aug 2004 08:14:07 -0700
Received: from internaldeliver.acheron.informatik.uni-muenchen.de (localhost [127.0.0.1])
	by acheron.informatik.uni-muenchen.de (Postfix) with ESMTP id C971F43609
	for <nfs@lists.sourceforge.net>; Tue, 24 Aug 2004 17:14:03 +0200 (CEST)
Received: from [141.84.1.141] (galois.bio.ifi.lmu.de [141.84.1.141])
	(using TLSv1 with cipher RC4-MD5 (128/128 bits))
	(No client certificate requested)
	by acheron.informatik.uni-muenchen.de (Postfix) with ESMTP id 9955B435C4
	for <nfs@lists.sourceforge.net>; Tue, 24 Aug 2004 17:14:03 +0200 (CEST)
To: nfs@lists.sourceforge.net
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

we run a diskless system where the clients boot via pxeboot, then
first mount / read-only from the server. Then we run our own
boot.nfsroot instead of /etc/init.d/boot and mount some directories
read-write per client, i.e., /var, /dev, /etc/local and /media.
Then a "client-script" is run on the client (still from within the
boot.nfsroot script) to setup some links to shared files,
copy some templates to /etc/local and "sed" some client-specific
values in the templaces. Normal stuff for a diskless setup I think.

Any failure in "client-script" causes a shutdown, assuming that sth.
essential went wrong during the client configuration in boot.nfsroot.

We mount the nfsroot and the client-directories with these options:
"nfsvers=3,tcp,hard,intr,nolock,rsize=8192,wsize=8192"

This all went fine with kernel 2.4.x. When we switched to 2.6.7, and up
to currently running 2.6.8.1, the "client-script" started to fail randomly.
Trying to trace the error down, playing around with some -x flags in
the scripts, or sleeps and more error messages, the failure changes
everytime I change some sleep or debugging output in either boot.nfsroot
or the client-script.

Here are the symptoms:
- It all started when on about every third boot, the clients
   complained
   "ln: /etc/local/printcap: File exists
    Error: Could not link shared file /etc/local/printcap"

   That was caused by a piece of code:

   for name in $SHARES
   do
     if ! ( rm -f $name && ln -s $COMMON/$name $name )
     then
       exitstatus=1
       echo "Error: Could not link shared file $name"
     fi
   done

   I think that the ln should never be allowed to complain
   with this messages because of the "rm ...&& ln.."

- in a different state of the script (some more sleeps, and client-script
   with -x) I got this:

   + cat /etc/local/fstab
   sed: Couldn't flush stdout: Stale NFS file handle
   + exitstatus=1

   The code was "cat $name | sed 's/...' > $name.tmp

- again from a different state with more sleeps etc. I got from somewhere
   in the client-script: (no -x here, and not debug output made it to the
   screen):

   nfs_update_inode: inode number mismatch
   expected (0:e/0x2c617b), got (0:e/0x2c6178)

- and finally the same with an additional sed error message:
   nfs_update_inode: inode number mismatch
   expected (0:e/0x2c617b), got (0:e/0x2c6178)
   sed: Couldn't flush <unknown>: Input/output error

Note that:
- when the script once has run, the system will boot without problems and
   run stable without any failure
- the problems are indepentend from mounting the nfsroot or the client-dirs
   with udp or tcp.

Just a guess: Could that be caused by mounting a /dev  directory for
the client over the /dev directory of the server within the boot.nfsroot
script? The boot.nfsroot script uses /dev/console and likely /dev/stdout
from the read-only-mounted /dev from the server, because it got the initial
console from this directory (with Neils patch with that MAY_LOCAL_ACCESS...)
Now when the scripts mounts the client-specific /dev, could that cause
a problem like the "Couldn't flush stdout: Stale NFS file handle"?

What could I do about this if that was the reason...? It never was a problem
with the 2.4 kernel...

I have a current setup where I can quite well reproduce the "nfs_update_inode
+ sed" error and the printcap problem so please let me know if I can do sth
to trace the error down.

Thanks for any hints!
cu,
Frank


-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049



-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
