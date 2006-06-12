From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [NFS] [RFC] NLM lock failover admin interface
Date: Mon, 12 Jun 2006 15:07:23 -0400
Message-ID: <448DBB6B.7000408@redhat.com>
References: <1150089943.26019.18.camel@localhost.localdomain>
	<448DA3F0.AF1C8540@sgi.com>
Reply-To: linux clustering <linux-cluster@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-cluster@redhat.com, nfs@lists.sourceforge.net
Return-path: <linux-cluster-bounces@redhat.com>
To: James Yarbrough <jmy@sgi.com>
In-Reply-To: <448DA3F0.AF1C8540@sgi.com>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/linux-cluster>,
	<mailto:linux-cluster-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-cluster>
List-Post: <mailto:linux-cluster@redhat.com>
List-Help: <mailto:linux-cluster-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-cluster>,
	<mailto:linux-cluster-request@redhat.com?subject=subscribe>
Sender: linux-cluster-bounces@redhat.com
Errors-To: linux-cluster-bounces@redhat.com
List-ID: <nfs.lists.sourceforge.net>

James Yarbrough wrote:

>>2. Adding a new flag into "exportfs" command, say "h", such that
>>
>>   "exportfs -uh *:/export_path"
>>
>>would un-export the entry and drop the NLM locks associated with the
>>entry.
>>    
>>
>
>This is fine for releasing the locks, but how do you plan to re-enter
>the grace period for reclaiming the locks when you relocate the export?
>And how do you intend to segregate the export for which reclaims are
>valid from the ones which are not?  How do you plan to support the
>sending of SM_NOTIFY?  This might be where a lockd per export has an
>advantage.
>
>  
>
Yeah, that's why Peter's idea (different lockd(s)) is also attractive. 
However, on the practical side, we don't plan to introduce kernel 
patches agressively. The approach is to be away from mainline NLM code 
base until we have enough QA cycles to make sure things work. The 
unexport part would allow other nfs services on the taken-over server 
un-interrupted. On the take-over server side, we currently do a global 
grace period. The plan has been to put a little delay before fixing 
take-over server's logic due to other NLM/posix lock issues - for 
example, the current (linux) NLM doesn't bother to call filesystem's 
lock method (which virtually disables any cluster filesystem's NFS 
locking across different NFS servers). However, if we have enough 
resources and/or volunteers, we may do these things in parallel. The 
following are planned:

Take-over server logic:
1. setup the statd sm file (currently /var/lib/nfs/statd/sm or the
    equivalent configured directory) properly.
2. rpc.statd is dispatched with "--ha-callout" option.
3. implement the ha-callout user mode program to create a seperate
    statd sm files for each exported ip.
4. export the target filesystem and set up grace period based on
    fsid (or devno). It will be used in NLM procedure calls by
    extracting the fsid (or devno) from nfs file handle to decide
    accepting or reject the not-reclaiming requests.
5. bring up the failover IP address.
6. send SM_NOTIFY to client machines using the configured sm
    directory created by the ha-callout program (rpc.statd -N -P).

Step 4 will be the counter-part of our unexport flag.

-- Wendy

 
