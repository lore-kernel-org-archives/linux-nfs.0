From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [RFC][PATCH 0/5] NFS: trace points added to mounting path
Date: Thu, 22 Jan 2009 08:07:43 -0500
Message-ID: <49786F9F.7030400@RedHat.com>
References: <4970B451.4080201@RedHat.com>	 <5B2817A2-B0FF-4FB5-9244-9E13C55EF6B2@oracle.com>	 <497757D1.7090908@RedHat.com>	 <F4767392-1D53-41C3-B96C-D71E3C4A6836@oracle.com>	 <1232566140.7692.64.camel@heimdal.trondhjem.org>	 <49777E4C.2020501@RedHat.com> <1232569427.7692.70.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Chuck Lever <chuck.lever@oracle.com>,         Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,         Linux NFS Mailing list <linux-nfs@vger.kernel.org>,         SystemTAP <systemtap@sources.redhat.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <systemtap-return-10991-gls-systemtap=m.gmane.org@sourceware.org>
In-Reply-To: <1232569427.7692.70.camel@heimdal.trondhjem.org>
List-Unsubscribe: <mailto:systemtap-unsubscribe-gls-systemtap=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:systemtap-subscribe@sourceware.org>
List-Post: <mailto:systemtap@sourceware.org>
List-Help: <mailto:systemtap-help@sourceware.org>, <http://sourceware.org/lists.html#faqs>
Sender: systemtap-owner@sourceware.org
List-ID: <linux-nfs.vger.kernel.org>



Trond Myklebust wrote:
> On Wed, 2009-01-21 at 14:58 -0500, Steve Dickson wrote:
>> Do we want to trace points:
>>     1) at all 
>>     2) for debugging 
>>     3) for performance
>>     4) 2 and 3
>>
>> Once we get the above nailed down then we can decide how to go...
> 
> I think it might be a good idea to flesh out a bit what you mean by
> "debugging" here. Since you mentioned it in conjunction with the two
> words "administrators" and "scripts", I assume that you are not talking
> about kernel code debugging?
I'm talking debugging for both admins and kernel people...

With trace points and systemtap you can do both.

steved.
