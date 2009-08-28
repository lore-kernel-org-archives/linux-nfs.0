From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/2] Enable v4 mounts when either "nfsvers=4" or "vers=4"
	option are set (vers-02)
Date: Fri, 28 Aug 2009 12:44:16 -0400
Message-ID: <8CA0476D-4E77-44A9-B895-561154381040@oracle.com>
References: <23199F1A-EA23-4DE1-AAB8-92D4B508C865@oracle.com>
	<4A956BF2.6000902@RedHat.com>
	<F805BE4F-BA72-4B13-A60A-B298C69611C8@oracle.com>
	<4A95760C.9000604@RedHat.com>
	<B26EBCDF-5836-440E-81D5-5E089158BFE1@oracle.com>
	<1251316764.5226.21.camel@heimdal.trondhjem.org>
	<4A9694D2.2030205@RedHat.com>
	<4A4EE1FA-209C-44D3-B418-96ABC18F9E3D@oracle.com>
	<20090828161256.GA2859@infradead.org> <4A980751.7070206@RedHat.com>
	<20090828164154.GB9951@infradead.org>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset="us-ascii"; Format="flowed"; DelSp="yes"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20090828164154.GB9951@infradead.org>
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

On Aug 28, 2009, at 12:41 PM, Christoph Hellwig wrote:
> On Fri, Aug 28, 2009 at 12:35:29PM -0400, Steve Dickson wrote:
>> Question... How are will it be to back out of this? Meaning the
>> kernel tries a v4 mount only to see the server does not support v4
>> or for some other recoverable error and then has to restart back
>> down the mount NFS again... This is very fairly trivial in user  
>> space...
>
> Same as we do now?  As soon as it doesn't work return an error, unwind
> and return to userspace?

If we handle NFSv4 in nfs_get_sb(), then we can handle version/ 
transport negotiation entirely in the kernel, which is another long  
term goal.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
