From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC][PATCH 0/5] NFS: trace points added to mounting path
Date: Fri, 23 Jan 2009 13:28:11 -0500
Message-ID: <54F36870-93F0-4154-A5AE-C9F22CD37EE3@oracle.com>
References: <4970B451.4080201@RedHat.com>	<5B2817A2-B0FF-4FB5-9244-9E13C55EF6B2@oracle.com>	<497757D1.7090908@RedHat.com>
	<F4767392-1D53-41C3-B96C-D71E3C4A6836@oracle.com>
	<497792EA.5040405@melbourne.sgi.com> <49788E71.3000306@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	SystemTAP <systemtap@sources.redhat.com>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
	Greg Banks <gnb@melbourne.sgi.com>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <49788E71.3000306@RedHat.com>
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

On Jan 22, 2009, at Jan 22, 2009, 10:19 AM, Steve Dickson wrote:
> Greg Banks wrote:
>> I think both dprintks and trace points are the wrong approach for
>> client-side mount problems.  What you really want there is good and
>> useful diagnostic information going unconditionally via printk().   
>> Mount
>> problems happen frequently enough, and are often not the client's  
>> fault
>> but the server's or a firewall's, that system admins need to be  
>> able to
>> work out what went wrong in retrospect by looking in syslog.
>>
>> But just because Steve chose an unfortunate example doesn't  
>> invalidate
>> his point.  There are plenty of gnarly logic paths in the NFS  
>> client and
>> server which need better runtime diagnostics.  On the server,   
>> anything
>> involving an upcall to userspace .  On the client, silly rename or
>> attribute caching.
> It appears I did pick an "unfortunate example"... since I was really
> trying to introduce trace points to see how they could be used...
> Maybe picking the I/O path would have been better...

Choosing mount was reasonable, as it's simple.  The discussion we are  
having about what tool is right for the job would have probably been  
less interesting if you had stuck with the I/O path.

The big picture though, is what do we need to do to make it easier to  
troubleshoot and solve problems.  That is a much bigger question than  
how we report errors.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
