From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [NFS] Re: [RFC] NLM lock failover admin interface
Date: Thu, 15 Jun 2006 11:09:41 -0400
Message-ID: <44917835.40805@redhat.com>
References: <1150089943.26019.18.camel@localhost.localdomain>
	<17550.11870.186706.36949@cse.unsw.edu.au>
	<1150268091.28264.75.camel@localhost.localdomain>
	<1150293654.28264.91.camel@localhost.localdomain>
	<20060615140743.36CDC1BBAD@citi.umich.edu>
Reply-To: linux clustering <linux-cluster@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net,
	linux clustering <linux-cluster@redhat.com>
Return-path: <linux-cluster-bounces@redhat.com>
To: "William A.(Andy) Adamson" <andros@citi.umich.edu>
In-Reply-To: <20060615140743.36CDC1BBAD@citi.umich.edu>
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

William A.(Andy) Adamson wrote:

>this discusion has centered around removing the locks of an export.
>we also want the interface to ge able to remove the locks owned by a single 
>client. this is needed to enable client migration between replica's or between 
>nodes in a cluster file system. it is not acceptable to place an entire export 
>in grace just to move a small number of clients.
>
>  
>
Andy,

Gotcha ... forgot about NFS V4. BTW, the discussion has moved back to 
/proc interface. I agree we need to add one more layer of granularity 
into it. Glad you caught this flaw.

-- Wendy
