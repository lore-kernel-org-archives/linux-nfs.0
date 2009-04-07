From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 3/5] nfs-utils: query for remote port using rpcbind
	instead of getaddrinfo
Date: Tue, 7 Apr 2009 13:12:22 -0400
Message-ID: <45A68BBE-E817-488B-A317-8C7562F2B102@oracle.com>
References: <1239117946-7535-1-git-send-email-jlayton@redhat.com>
	<1239117946-7535-4-git-send-email-jlayton@redhat.com>
	<41F98279-F000-4C1C-8E44-3568C89FC2BD@oracle.com>
	<20090407162005.GC24157@fieldses.org>
	<65C78FA4-2A84-498E-8857-BBB6F59B206C@oracle.com>
	<20090407163253.GD24157@fieldses.org>
	<F735CA3E-70ED-4352-92F8-C440EC18FA2E@oracle.com>
	<20090407130058.2493457e@tleilax.poochiereds.net>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20090407130058.2493457e@tleilax.poochiereds.net>
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

On Apr 7, 2009, at 1:00 PM, Jeff Layton wrote:
> On Tue, 7 Apr 2009 12:34:54 -0400
> Chuck Lever <chuck.lever@oracle.com> wrote:
>
>> On Apr 7, 2009, at 12:32 PM, J. Bruce Fields wrote:
>>> On Tue, Apr 07, 2009 at 12:29:23PM -0400, Chuck Lever wrote:
>>>> On Apr 7, 2009, at 12:20 PM, J. Bruce Fields wrote:
>>>>> In recent kernels that information is in the "info" file for the
>>>>> given
>>>>> client in rpc_pipefs.  Kevin and Olga have patches to support that
>>>>> in
>>>>> gssd, if they aren't already in upstream nfs-utils.
>>>>
>>>> The issue is we're not exactly sure what value the kernel is
>>>> passing up
>>>> in the info file.  It seems to change over time.
>>>
>>> I don't understand.  How does it change over time?
>>
>> Jeff observed some strange behavior while testing yesterday, so I'll
>> let him address this question.
>>
>
> I sort of had expected to see the "port" value in the info file change
> once the kernel had done the rpcbind query and set the port in the
> socket. It doesn't do this though. In hindsight I think the current
> behavior is actually correct. The port value here more or less
> represents the port that was given to the kernel at mount time.
>
>> The rules for how the kernel uses the port= setting are:
>>
>>  + if port= is not specified on NFSv2/v3, port= setting is zero
>>  + if port= is not specified on NFSv4, port= setting is 2049
>>
>> Then, when setting up a tranport:
>>
>>  + if the port= setting is zero, do an rpcbind
>>  + if the port= setting is not zero, use that value
>
> I think this patchset provides the behavior you want. For recent
> kernels that provide the port: field in the "info" file:
>
> nfsv4: port: 2049
> nfsv2/3: port: 0
>
> ...if you set port= in the mount options, then the info file displays
> that port.
>
> When we have an older kernel that does not display the port, then
> populate_port() will see that sin(6)_port is still 0. For nfsv2/3  
> it'll
> do an rpcbind query to get the port, but we don't want to do that for
> NFSv4, so I added this:
>
> +       /* Use standard NFS port for NFSv4 */
> +       if (program == 100003 && version == 4) {
> +               port = 2049;
> +               goto set_port;
> +       }
>
> The important bit is that the above chunk will only matter for kernels
> that don't have a port: field in the info file.

Ah.  I think the comment should mention this is for supporting legacy  
kernels.

> In short, I think the behavior with this set is what you've outlined
> above.

Good.  Ship it ;-)

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
