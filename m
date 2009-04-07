From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 3/5] nfs-utils: query for remote port using rpcbind
	instead of getaddrinfo
Date: Tue, 7 Apr 2009 12:34:54 -0400
Message-ID: <F735CA3E-70ED-4352-92F8-C440EC18FA2E@oracle.com>
References: <1239117946-7535-1-git-send-email-jlayton@redhat.com>
	<1239117946-7535-4-git-send-email-jlayton@redhat.com>
	<41F98279-F000-4C1C-8E44-3568C89FC2BD@oracle.com>
	<20090407162005.GC24157@fieldses.org>
	<65C78FA4-2A84-498E-8857-BBB6F59B206C@oracle.com>
	<20090407163253.GD24157@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20090407163253.GD24157@fieldses.org>
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

On Apr 7, 2009, at 12:32 PM, J. Bruce Fields wrote:
> On Tue, Apr 07, 2009 at 12:29:23PM -0400, Chuck Lever wrote:
>> On Apr 7, 2009, at 12:20 PM, J. Bruce Fields wrote:
>>> In recent kernels that information is in the "info" file for the  
>>> given
>>> client in rpc_pipefs.  Kevin and Olga have patches to support that  
>>> in
>>> gssd, if they aren't already in upstream nfs-utils.
>>
>> The issue is we're not exactly sure what value the kernel is  
>> passing up
>> in the info file.  It seems to change over time.
>
> I don't understand.  How does it change over time?

Jeff observed some strange behavior while testing yesterday, so I'll  
let him address this question.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
