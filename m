From: "Gui,Jian" <guij@cn.ibm.com>
Subject: Re: [NFS] draft RPC tapset
Date: Wed, 06 Sep 2006 10:32:34 +0800
Message-ID: <44FE3342.9050200@cn.ltcfwd.linux.ibm.com>
References: <44FD393F.8080202@cn.ltcfwd.linux.ibm.com> <44FD64CE.8080606@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: systemtap@sources.redhat.com, nfs@lists.sourceforge.net
Return-path: <systemtap-return-4109-gls-systemtap=m.gmane.org@sourceware.org>
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <44FD64CE.8080606@RedHat.com>
List-Unsubscribe: <mailto:systemtap-unsubscribe-gls-systemtap=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:systemtap-subscribe@sourceware.org>
List-Post: <mailto:systemtap@sourceware.org>
List-Help: <mailto:systemtap-help@sourceware.org>, <http://sourceware.org/lists.html#faqs>
Sender: systemtap-owner@sourceware.org
List-ID: <nfs.lists.sourceforge.net>

Steve Dickson wrote:
> 
> Question, should these probs be broken up into separate files?
> and if so, where do they need to live so they will be defined
> by the stap command?
> 
Thanks. I use a single file now since I was afraid each RPC
component uses a small file might mess up the systemtap tapset
dir. I will try to separate it if it becomes worse :-)

This is a generic tapset. You can use it like Frank said.

I am writing its LKET implementation so that we can use easier way
to provide more information, including common info(timestamp, pid,
cpu, etc) and trace hook specific data as well. Your suggestions
about which data should be recorded will be very appreciated.

-Gui,Jian
