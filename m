From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [Patch 0/9] NFS Mount Configuration File
Date: Tue, 17 Mar 2009 16:36:26 -0400
Message-ID: <44E15D54-622B-42BA-8EB9-FE73B99D8067@oracle.com>
References: <49B57FB2.9020000@RedHat.com>
	<A359B7ED-198B-4C3E-96B1-F4B2D5D3582B@oracle.com>
	<49BFFDA6.8090500@RedHat.com>
	<C0503E0B-59F4-46BA-9430-08C34B2F693E@oracle.com>
	<20090317202501.GD32331@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20090317202501.GD32331@fieldses.org>
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

On Mar 17, 2009, at Mar 17, 2009, 4:25 PM, J. Bruce Fields wrote:
> On Tue, Mar 17, 2009 at 04:17:05PM -0400, Chuck Lever wrote:
>> I think the problem I have with this (besides the complexity) is that
>> if we must add more ways of avoiding NFSv4, then is NFSv4 really  
>> ready
>> to be made the default?
>
> Even given the best possible client and server implementation, there  
> are
> enough user-visible not-completely-backwards-compatible changes in the
> protocol (ACLs, string names, etc.) that silently substituting v4  
> can't
> be the right thing for every case.

For the cases where it isn't right, why is simply adding "vers=3" not  
an appropriate workaround?

It would be nice to have a working list of areas where there are going  
to be issues, so we and our users can be prepared for the transition.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
