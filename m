From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/2] Enable v4 mounts when either "nfsvers=4" or "vers=4"
	option are set (vers-02)
Date: Thu, 27 Aug 2009 13:58:57 -0400
Message-ID: <41843262-CA6A-47A3-94C0-69F7711944EC@oracle.com>
References: <4A9424DB.2040303@RedHat.com> <4A942593.8030101@RedHat.com>
	<CF5F0448-E859-4EA2-805B-909B8C907533@oracle.com>
	<4A943914.9020104@RedHat.com>
	<7AB7BC01-F9E5-4611-BB4B-2B6E27069631@oracle.com>
	<4A944645.1020003@RedHat.com>
	<1251233345.25372.67.camel@heimdal.trondhjem.org>
	<B62E906B-F215-4400-B48D-DDE2C8428F9E@oracle.com>
	<4A954FBF.3030606@RedHat.com>
	<23199F1A-EA23-4DE1-AAB8-92D4B508C865@oracle.com>
	<4A956BF2.6000902@RedHat.com>
	<F805BE4F-BA72-4B13-A60A-B298C69611C8@oracle.com>
	<4A95760C.9000604@RedHat.com>
	<B26EBCDF-5836-440E-81D5-5E089158BFE1@oracle.com>
	<1251316764.5226.21.camel@heimdal.trondhjem.org>
	<4A9694D2.2030205@RedHat.com>
	<1251395324.5173.21.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset="us-ascii"; Format="flowed"; DelSp="yes"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1251395324.5173.21.camel@heimdal.trondhjem.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 27, 2009, at 1:48 PM, Trond Myklebust wrote:

> On Thu, 2009-08-27 at 10:14 -0400, Steve Dickson wrote:
>> I say we go with the proposed patch since its simple, architecturally
>> sound, will not cause problems down the road as long as nfs4 remains
>> a standalone file system and its done! Plus I have a patch waiting
>> in the wings that actually does make v4 the first mount that is
>> tried... making v4 the default version...
>
> I do worry that if, at some point, we do get rid of the nfs4  
> filesystem
> alias then we may find ourselves in trouble if we have a large base of
> mount programs out there that translate '-t nfs -overs=4' into '-t
> nfs4'.
>
> I think that if you want to go down this path, you should somehow  
> ensure
> that the resulting program is capable of passing '-t nfs -overs=4'  
> down
> to the kernel (perhaps a configuration file option?).

My impression was that this mount command behavior would be controlled  
with a kernel version switch in mount.nfs, much the same way that we  
already handle switching between text-based and legacy mounting.  That  
won't help with old nfs-utils on new kernels, though.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
