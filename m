From: Yuan Xu <yuan@pauli.utmb.edu>
Subject: NFS server problem with kernel 2.6.8.1
Date: Tue, 17 May 2005 15:44:49 -0500
Message-ID: <428A57C1.7070807@pauli.utmb.edu>
Reply-To: yuan@pauli.utmb.edu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DY8w5-0007Xm-TM
	for nfs@lists.sourceforge.net; Tue, 17 May 2005 13:45:05 -0700
Received: from mx4.utmb.edu ([129.109.195.9])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DY8w4-0005PD-0L
	for nfs@lists.sourceforge.net; Tue, 17 May 2005 13:45:05 -0700
Received: from pauli.utmb.edu (pauli.utmb.edu [129.109.59.102])
	by mx4.utmb.edu (8.12.11/8.12.11) with ESMTP id j4HKjFUe004045
	for <nfs@lists.sourceforge.net>; Tue, 17 May 2005 15:45:15 -0500
To: nfs@lists.sourceforge.net
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

Dear all
This problem is caused by running up2date of Redhat linux!!!

When I was running  kernel  2.4.21-27.0.2.ELsmp my nfs server worked 
fine and after upgrading to 2.6.x via Redhat RHN my NFS sever no longer 
works.
Right now the NFS server is running kernel 2.6.8.1 SMP, x86_64 and I can 
mount to all other machines from this server and got no problems but 
when try to mount other machines to the server via NFS I always got 
error messages such that:
mount: carnot:/home/people failed, reason given by server: Permission 
denied.
I have NFS servers running on kernel 2.4.x and 2.6.11-1.14_FC3 machines 
and they all work fine but this 2.6.8.1 machine
The permission of people directory is fine as comparing with the 
directories exported on other NFS servers.

On my 2.6.8.1 server I checked via rpcinfo and got:
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  32768  status
    100024    1   tcp  32768  status
    100021    1   udp  32769  nlockmgr
    100021    3   udp  32769  nlockmgr
    100021    4   udp  32769  nlockmgr
    100021    1   tcp  32769  nlockmgr
    100021    3   tcp  32769  nlockmgr
    100021    4   tcp  32769  nlockmgr
    391002    2   tcp  32770  sgi_fam
    100011    1   udp    931  rquotad
    100011    2   udp    931  rquotad
    100011    1   tcp    934  rquotad
    100011    2   tcp    934  rquotad
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100005    1   udp    945  mountd
    100005    1   tcp    948  mountd
    100005    2   udp    945  mountd
    100005    2   tcp    948  mountd
    100005    3   udp    945  mountd
    100005    3   tcp    948  mountd
    300019    1   tcp    956  amd
    300019    1   udp    957  amd
It looks fine comparing with other NFS servers.

But I could not see sunrpc loaded when I ran lsmod on this server, and 
all other NFS server show:
 lsmod | grep sun
sunrpc                 91880   1  (autoclean) [nfs nfsd lockd]

It seems the sunrpc module is not loaded. Checked the server's /boot and 
found config-2.4.21-27.0.2.ELsmp but do not see
 file like config-2.6.8.1.x . Checked modprobe and it returned:

modprobe sunrpc
FATAL: Module sunrpc not found.
FATAL: Error running install command for sunrpc

Is the NFS problem caused by this sunrpc? and if so
do I have to recompile the kernel to load this sunrpc or any quick fix 
of the problem

Any help will be much appreciated

Yuan

-- 
Have a good day

Yuan
4097476805(O), 2816145220(H)
yuan@pauli.utmb.edu
http://www.scsb.utmb.edu
http://www.scsb.utmb.edu/Compu_Core/index.html
http://pauli.utmb.edu/yuan





-------------------------------------------------------
This SF.Net email is sponsored by Oracle Space Sweepstakes
Want to be the first software developer in space?
Enter now for the Oracle Space Sweepstakes!
http://ads.osdn.com/?ad_id=7412&alloc_id=16344&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
