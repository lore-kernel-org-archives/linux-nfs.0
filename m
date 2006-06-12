From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [NFS] [RFC] NLM lock failover admin	interface
Date: Mon, 12 Jun 2006 14:09:30 -0400
Message-ID: <448DADDA.2070209@redhat.com>
References: <1150089943.26019.18.camel@localhost.localdomain>
	<20060612150053.GC31596@fieldses.org>
	<448D8BF7.7010105@redhat.com> <448DE1C1.C935.0084.1@novell.com>
Reply-To: linux clustering <linux-cluster@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux clustering <linux-cluster@redhat.com>,
	nfs@lists.sourceforge.net
Return-path: <linux-cluster-bounces@redhat.com>
To: Madhan P <PMadhan@novell.com>
In-Reply-To: <448DE1C1.C935.0084.1@novell.com>
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

Madhan P wrote:

>For what it's worth, would second this approach of using a flag to
>unexport and associating the cleanup with that. 
>

Happy to have another vote :)  !  It is appreicated.

> Another quick hack we
>used was to store the NSM entries on a standard location on the
>respective exported filesystem, so that notification is sent once the
>filesystem comes back online on the destination server and is exported
>again.  BTW, this was not on Linux. It was a  simple solution providing
>the necessary active/active and active/passive cluster support.
>  
>

Lon Hohberge (from our cluster suite team) has been working on similar 
setup too (to structure the MSM file directory). We'll submit the 
associated kernel patch when it is ready ("rpc.statd -H" needs some 
bandaids). Future reviews and comments are also appreciated.

-- Wendy
