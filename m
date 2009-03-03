From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Locked system
Date: Tue, 3 Mar 2009 12:34:43 -0500
Message-ID: <20090303173443.GI22184@fieldses.org>
References: <e77a196d0902241947wdaaa021le11d11fd607f60bc@mail.gmail.com>
	<e77a196d0903021909w78b426f1kcb2a69b6fad58abf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com
To: David Bartley <dtbartle@csclub.uwaterloo.ca>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <e77a196d0903021909w78b426f1kcb2a69b6fad58abf@mail.gmail.com>
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

On Mon, Mar 02, 2009 at 10:09:57PM -0500, David Bartley wrote:
> Hi,
> 
> I'm wondering if anybody has had a chance to look at this?

What's the client kernel version?  What's the server?  Can you get a
network trace?  (tcpdump -s0 -wTMP, send us TMP).

--b.

> 
> Thanks,
> David
> 
> On Tue, Feb 24, 2009 at 10:47 PM, David Bartley
> <dtbartle@csclub.uwaterloo.ca> wrote:
> > Hello,
> >
> > A system I administer partially locked due to an apparent NFS4
> > problem. I've attached the trace I found in kern.log. Let me know if
> > you need any additional information.
> >
> > -- David
> >
