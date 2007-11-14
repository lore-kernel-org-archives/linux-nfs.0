From: Harshula <harshula@sgi.com>
Subject: Re: libnfsidmap
Date: Wed, 14 Nov 2007 18:11:52 +1100
Message-ID: <1195024312.19850.130.camel@serendib.melbourne.sgi.com>
References: <1193136846.5620.504.camel@serendib.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IsCQl-00073i-Bu
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 23:12:59 -0800
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX1/VPlVtYmoDInwr+PVymMAUVbKisKSNVsY=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IsCQp-0006h7-S7
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 23:13:05 -0800
In-Reply-To: <1193136846.5620.504.camel@serendib.melbourne.sgi.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi Kevin,

On Tue, 2007-10-23 at 20:54 +1000, Harshula wrote:
> Hi Bruce,
> 
> We are building nfs-utils 1.0.7 with libnfsidmap 0.20 to avoid a bug
> with userid mappings in libnfsidmap 0.12.
> 
> Then we tripped over nfs/<FQDN> principals not being resolved. Luckily I
> came across:
> http://linux-nfs.org/pipermail/nfsv4/2006-June/004564.html
> 
> and realised that the code to handle nfs/<FQDN> principals is now in
> nfs-utils (utils/gssd/svcgssd_proc.c).

re: utils/gssd/svcgssd_proc.c:
-----------------------------------------------------
/*
 * -ENOENT means there was no mapping, any other error
 * value means there was an error trying to do the
 * mapping.
 * If there was no mapping, we send down the value -1
 * to indicate that the anonuid/anongid for the export
 * should be used.
 */
if (res == -ENOENT) {
        cred->cr_uid = -1;
        cred->cr_gid = -1;
        cred->cr_ngroups = 0;
        res = 0;
        goto out_free;
}
-----------------------------------------------------

What happens if the server has an export with the no_root_squash option?

I did a quick test with the above code snippet backported to nfs-utils
1.0.7 and found that an export with no_root_squash would still
root_squash.

By doing:
-----------------------------------------------------
/*
 * -ENOENT means there was no mapping, any other error
 * value means there was an error trying to do the
 * mapping.
 */
if (res == -ENOENT && strncmp(sname, "nfs/", 4) == 0) { 
        cred->cr_uid = 0;
        cred->cr_gid = 0;
        cred->cr_ngroups = 0;
        res = 0;
        goto out_free;
}  
-----------------------------------------------------

The root_squash/no_root_squash behaviour was as expected. Is there any
problem with mapping to root UID iff the name has the "nfs/" prefix?

cya,
#


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
