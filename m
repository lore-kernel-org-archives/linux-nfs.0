From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Linux client on Solaris 7 NFS server
Date: Wed, 24 Dec 2003 17:30:42 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FEA1392.7010502@RedHat.com>
References: <3FE9ACDB.4060004@nsc1.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AZHWj-0002bd-N4
	for nfs@lists.sourceforge.net; Wed, 24 Dec 2003 14:30:49 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AZHWj-0005iX-DO
	for nfs@lists.sourceforge.net; Wed, 24 Dec 2003 14:30:49 -0800
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.11.6/8.11.6) with ESMTP id hBOMUgA25010
	for <nfs@lists.sourceforge.net>; Wed, 24 Dec 2003 17:30:42 -0500
Received: from RedHat.com (vpn50-36.rdu.redhat.com [172.16.50.36])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id hBOMUgE30453
	for <nfs@lists.sourceforge.net>; Wed, 24 Dec 2003 17:30:42 -0500
To: nfs@lists.sourceforge.net
In-Reply-To: <3FE9ACDB.4060004@nsc1.net>
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

Wade Hampton wrote:

> I have a Fedora Core 1.0 client connecting to a
> Solaris X86 Version 7 NFS server.  The Solaris server
> has locked up several times since I started accessing
> it from Linux (this is the only change to the Solaris
> system's environment).  I was wondering if this
> was an NFS problem on Solaris 7 or could be a
> hardware problem with the NIC.

A network trace of the lockup would be good...

SteveD.



-------------------------------------------------------
This SF.net email is sponsored by: IBM Linux Tutorials.
Become an expert in LINUX or just sharpen your skills.  Sign up for IBM's
Free Linux Tutorials.  Learn everything from the bash shell to sys admin.
Click now! http://ads.osdn.com/?ad_id=1278&alloc_id=3371&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
