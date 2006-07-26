From: "Yatin Manerker" <ymanerker@novell.com>
Subject: Re: NFSv4 Active-Active Cluster Queries
Date: Wed, 26 Jul 2006 02:58:31 -0600
Message-ID: <44C77C0F.52A0.00C4.0@novell.com>
References: <44BCC5620200007F0000E2C6@lucius.provo.novell.com>
	<44BCD1F80200007F0000E2CA@lucius.provo.novell.com>
	<44BCE7BB0200007F0000E2E7@lucius.provo.novell.com>
	<44BF54250200007F0000E3E0@lucius.provo.novell.com>
	<44BF5EF80200007F0000E3E4@lucius.provo.novell.com>
	<44BF5F580200007F0000E3E7@lucius.provo.novell.com>
	<44BF5F8B0200007F0000E3EA@lucius.provo.novell.com>
	<44BF607D0200007F0000E3ED@lucius.provo.novell.com>
	<44BF6B4F0200007F0000E3F6@lucius.provo.novell.com>
	<44BF6B870200007F0000E3F9@lucius.provo.novell.com>
	<44BF6BA30200007F0000E3FC@lucius.provo.novell.com>
	<44BF6BE60200007F0000E3FF@lucius.provo.novell.com>
	<44BF6BE5.6FDC.007F.0@novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfsv4-bounces@linux-nfs.org>
To: "J. Bruce Fields"<bfields@fieldses.org>,<nfsv4@linux-nfs.org>
In-Reply-To: <44BF6BE5.6FDC.007F.0@novell.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

>Yes.  Even active- passive failover is problematic right now, mainly
> because the method we use for storing reboot recovery information
> (analagous to the state recorded by statd) is still in flux.

> We're aware of these problems and working on solving them.  There
are
> some rough (possibly out of date notes) here:

> http://wiki.linux-nfs.org/index.php/Cluster_Coherent_NFS_design

> but those are more of interest to someone working on design of a
> solution than to someone trying to set up and use any of this (which
we
> don't recommend doing yet). 

> -- b.

Hi 
 We have tested NFSv4 in Active/Passive HA clusters. I wanted to know
if we have missed out anything test scenarios. I have not found any
issues in the following test scenarios.
Here are the test results

Server: Suse Linux Enterprise server 10 
Build : RC3
Kernel: 2.6.16.21
Hardware details: Server -> 32 bit hardware 2P - P4 2Gb RAM
HA clusters : Active/Passive
Client hardware: 1P, P3-512 MB RAM

Following scenarios are tested and passed for Active/Passive HA
clusters (iSCSI )

1.Client connection during failover and failback scenarios. Tested with
40 clients. 
2.Large file transfer from 4 clients. Single file size of 8GB from each
client.  Test was performed during failover and  failback scenarios.    
                        
3.File listing : File listing was done from 40 clients. (A single
directory having 0.9 million files).
4.Recovery test: Physical link breakage and Power down recovery when
client is running test(connect athon) on NFS mounted volume.
5.Backward compatibility : NFSv3/v4 client connecting NFSv4/v3 server
6.Interop: Novell iFolder client data on NFSv4 mount point.NFSv4 client
mounting NFSv4 exported file system and iFolder client storing data on
the remote NFS file system
7.iozone and connect athon test executed for NFSv4 client in cluster
environment
  
            
Following scenarios are tested and passed for Active/Passive HA
clusters (DRBD ) (for single client )

1.Client connection during failover and failback scenarios. (V3 and V4
client)
2.Directory listing (v3 and v4 client)
3.Executed Connect athon test  (Lock testing is done as part of this
test)
        
                   
Regards,
Yatin  
