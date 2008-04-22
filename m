From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Problem with krb5 authentification, server under a NAT
Date: Tue, 22 Apr 2008 12:56:20 -0400
Message-ID: <20080422165620.GF16695@fieldses.org>
References: <20080422161908.GC11221@goelette.ens.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org, aglo@citi.umich.edu
To: Quentin Godfroy <godfroy@clipper.ens.fr>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20080422161908.GC11221@goelette.ens.fr>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 22, 2008 at 06:19:09PM +0200, Quentin Godfroy wrote:
> Hi,
> 
> I have a problem with krb5 authentification and nfsv4:
> 
> basically the server is behind a NAT which over I do not have much control.
> To mount exported partitions I use socat on the NAT and redirect some TCP port
> (actually 2050 because 2049 is firewalled) to the port 2049 on the server. I
> can successfuly mount with auth=sys,port=2050, but I am unable to mount with
> kerberos authentification. The problem seems to lie within rpc.gssd which does
> not care for the port setting and tries to contact the server on port 2049.
> 
> I suppose the same could happen with nfsv{2,3} (provided the mountd port is
> redirected as well)
> 
> Is this a problem you were aware of?
> 
> I suppose fixing it may require a change in the callback between the kernel
> and rpc.gssd?

What kernel are you on?  As of 2.6.24 (more specifically:

	bf19aacecbeebccb2c3d150a8bd9416b7dba81fe "nfs: add server port
	to rpc_pipe info file"

the kernel does give gssd the information it needs to figure out which
port the server is on.

Looks to me like gssd doesn't yet use that yet, though.  Olga, did you
have a patch to make gssd read the "port:" line from the info file?

--b.
