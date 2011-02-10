Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-out-1.desy.de ([131.169.56.84]:47603 "EHLO
	smtp-out-1.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752811Ab1BJSmG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Feb 2011 13:42:06 -0500
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-out-1.desy.de (DESY_OUT_1) with ESMTP id CAD7719CD
	for <linux-nfs@vger.kernel.org>; Thu, 10 Feb 2011 19:41:58 +0100 (MET)
Received: from adserv70.win.desy.de (adserv70.win.desy.de [131.169.97.56])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id C10D013EDD
	for <linux-nfs@vger.kernel.org>; Thu, 10 Feb 2011 19:41:58 +0100 (MET)
Message-ID: <4D543176.20809@desy.de>
Date: Thu, 10 Feb 2011 19:41:58 +0100
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: nfsv4@ietf.org, NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [nfsv4] Data is not showing at Data server in an pNFS setup
References: <A1A98FD909DC5248811A65C5D18E9C761D55096825@BLRX7MCDC202.AMER.DELL.COM>
In-Reply-To: <A1A98FD909DC5248811A65C5D18E9C761D55096825@BLRX7MCDC202.AMER.DELL.COM>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Taousif,

first of all, I think you have to use linux-nfs mailing list instead of
ietf one.

anyway, check that layout driver is loaded ( lsmod ). Check as well that
in /etc/modprobe.d exists a file with folloing line:

alias nfs-layouttype4-1 nfs_layout_nfsv41_files


Regards,
Tigran.
On 02/10/2011 01:44 PM, Taousif_Ansari@DELLTEAM.com wrote:
> Hi,
> I’m setting up an pNFS,
> I’ve installed the pnfs kernel and pnfs-utils.
> Following the way given at
> _http://wiki.linux-nfs.org/wiki/index.php/Configuring_pNFS/spnfsd#Configuring_the_pNFS_Metadata_Server_
> <http://wiki.linux-nfs.org/wiki/index.php/Configuring_pNFS/spnfsd>
> Copied the utils to /usr/sbin
> cp utils/exportfs/exportfs /usr/sbin/exportfs
> cp utils/mountd/mountd /usr/sbin/rpc.mountd
> cp utils/mountd/nfsd /usr/sbin/rpc.nfsd
> cp utils/nfsstat/nfsstat /usr/sbin/nfsstat
> Configuration –
> On data server
> I’ve created a directory /export/spnfs
> And the /etc/export is like
> /export/spnfs
> *(rw,sync,fsid=0,insecure,no_subtree_check,pnfs,no_root_suquash)
> On Metadata server
> I’ve created a directory /export
> And the /etc/export is like
> /export *(rw,sync,pnfs,fsid=0,insecure,no_subtree_check,no_root_squash)
> And copied the spnfs.conf which looks like
> [General]
> Verbosity = 1
> Stripe-size = 8192
> Dense-striping = 0
> Pipefs-Directory = /var/lib/nfs/rpc_pipefs
> DS-Mount-Directory = /spnfs
> [DataServers]
> NumDS = 1
> DS1_IP = <DS-IP>
> DS1_PORT = 2049
> DS1_ROOT = /
> DS1_ID = 1
> On client
> Inserted the module nfs_layout_nfsv41_files
> # modprobe nfs_layout_nfsv41_files
> Then mounted the MDS on client
> # mount -t nfs4 -o minorversion=1 nfsmds:/ /mnt
> In client’s /mnt directory, created a file hello
> #cat > hello
> Welcome to pNFS.
> ^c
> On MDS in /export I’m able to see the file and contents also.
> But on Data server in directory /export/spnfs/ nothing it is showing.
> Thank you,
> Taousif
>
>
> _______________________________________________
> nfsv4 mailing list
> nfsv4@ietf.org
> https://www.ietf.org/mailman/listinfo/nfsv4
>   

