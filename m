From: Tupshin Harper <tupshin@tupshin.com>
Subject: Help needed with NFS locking
Date: Sat, 19 Jul 2003 12:59:03 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F19A307.3090102@tupshin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from adsl-67-114-19-186.dsl.pltn13.pacbell.net ([67.114.19.186] helo=adsl-63-202-77-221.dsl.snfc21.pacbell.net)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19dxrC-00061v-00
	for <nfs@lists.sourceforge.net>; Sat, 19 Jul 2003 12:59:02 -0700
To: nfs@lists.sourceforge.net
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

I'm absolutely stuck on this one. I'm running linux-2.4.21-ac4 on both 
client and server (problem is not unique to this version of the kernel), 
with debian-sid distribution on both systems. I'm trying to run /home as 
an NFS-mounted volume on the client, but no matter what I try, I can't 
get nfs-locking to work.

rpcinfo -p on the server looks like this:
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp    665  status
    100024    1   tcp    668  status
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100021    1   udp  41255  nlockmgr
    100021    3   udp  41255  nlockmgr
    100021    4   udp  41255  nlockmgr
    100021    1   tcp  49464  nlockmgr
    100021    3   tcp  49464  nlockmgr
    100021    4   tcp  49464  nlockmgr
    100005    1   udp    728  mountd
    100005    1   tcp    731  mountd
    100005    2   udp    728  mountd
    100005    2   tcp    731  mountd
    100005    3   udp    728  mountd
    100005    3   tcp    731  mountd

and on the client:
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100021    1   udp  32768  nlockmgr
    100021    3   udp  32768  nlockmgr
    100021    4   udp  32768  nlockmgr
    100021    1   tcp  32768  nlockmgr
    100021    3   tcp  32768  nlockmgr
    100021    4   tcp  32768  nlockmgr
    391002    1   tcp    772  sgi_fam
    391002    2   tcp    772  sgi_fam
    100024    1   udp    652  status
    100024    1   tcp    655  status

And doing a remote rpcinfo between the two machines shows the same 
information.

The symptom exihibits itself mainly as an inability to use gnome due to 
file-locking errors, but other applications provide locking warnings as 
well. BTW, is there a canonical way to test for nfs-locking?


Any suggestions???

-Tupshin



-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines at the
same time. Free trial click here: http://www.vmware.com/wl/offer/345/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
