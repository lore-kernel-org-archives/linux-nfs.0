From: "Shane Presley" <shane.presley@gmail.com>
Subject: Re: Problem with NFS from RedHat4 to Solaris
Date: Wed, 25 Oct 2006 11:10:31 -0400
Message-ID: <27ae92160610250810i2b8803f5xbb959f7fd093f47b@mail.gmail.com>
References: <27ae92160610241005x7c7bca01v4986fc40d77fba19@mail.gmail.com>
	<453F7084.7070601@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GckOx-0002EN-E0
	for nfs@lists.sourceforge.net; Wed, 25 Oct 2006 08:10:43 -0700
Received: from nf-out-0910.google.com ([64.233.182.190])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GckOu-0007cm-0o
	for nfs@lists.sourceforge.net; Wed, 25 Oct 2006 08:10:41 -0700
Received: by nf-out-0910.google.com with SMTP id p46so895073nfa
	for <nfs@lists.sourceforge.net>; Wed, 25 Oct 2006 08:10:32 -0700 (PDT)
To: "Steve Dickson" <SteveD@redhat.com>
In-Reply-To: <453F7084.7070601@RedHat.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On 10/25/06, Steve Dickson <SteveD@redhat.com> wrote:
> ah... port=0 means it can't get server's port number for lockd...
> make sure the lockd on the server is running...
>


Very interesting...and you're correct....this mount is on my Solaris servers
rpcinfo -p solarisserver
   program vers proto   port
    100000    4   tcp    111  portmapper
    100000    3   tcp    111  portmapper
    100000    2   tcp    111  portmapper
    100000    4   udp    111  portmapper
    100000    3   udp    111  portmapper
    100000    2   udp    111  portmapper
    100005    1   udp  35185  mountd
    100005    2   udp  35185  mountd
    100005    3   udp  35185  mountd
    100005    1   tcp  54469  mountd
    100005    2   tcp  54469  mountd
    100005    3   tcp  54469  mountd
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100227    2   udp   2049  nfs_acl
    100227    3   udp   2049  nfs_acl
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100227    2   tcp   2049  nfs_acl
    100227    3   tcp   2049  nfs_acl


No nlockmgr.  But for some reason when my RHEL3 system mounts this
server, it still works.  Anyway, now I have to dig into my Solaris box
to see why nlockmgr isn't working.

But any idea why RHEL3 would still work fine?

Thanks
Shane

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
