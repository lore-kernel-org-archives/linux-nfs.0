From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [RFC][PATCH 0/5] NFS: trace points added to mounting path
Date: Tue, 20 Jan 2009 10:13:07 +1100
Message-ID: <49750903.90104@melbourne.sgi.com>
References: <4970B451.4080201@RedHat.com> <49711BDF.3010605@melbourne.sgi.com>
	<y0mmydpucww.fsf@ton.toronto.redhat.com>
	<4973B777.2000102@melbourne.sgi.com>
	<20090119154133.GE1574@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
	SystemTAP <systemtap@sources.redhat.com>
To: "Frank Ch. Eigler" <fche@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20090119154133.GE1574@redhat.com>
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

Frank Ch. Eigler wrote:
> Hi -
>
> On Mon, Jan 19, 2009 at 10:12:55AM +1100, Greg Banks wrote:
>   
>> [...]
>>     
>>> It would make more sense to me to turn dprintk's into trace_marks, 
>>>       
>> Umm, ok.  Sorry to be so ignorant but where would I find the doc that
>> tells me about adding trace marks ?
>>     
>
> Documentation/markers.txt
>   

Thanks.
>   
>> The control interface seems a little primitive.  It seems like you
>> can only activate and deactivate single printks ?
>>     
>
> Or single classes (identical names) per activate/deactivate call.
>
>   
The problem with this "classes" approach -- which sounds to my ignorant
ears like the "facilities" feature of nfs/sunrpc dprintks -- is
predicting which combination of classes to define so that they're useful
in the field years later with unknown bugs and unknown load patterns.  I
found that querying by function name was more useful in practice.
>
> [...]
> - it could generalize the handling of these dprintks, by not just
>   being tied to message printing, but becoming of possible use for
>   statistics/health monitoring
>   

That sounds potentially useful.  I was considering extending my dprintk
patch to add a flag to optionally bump a counter when the dprintk() line
is executed, but doing it via trace markers could be more useful if less
performant.

Let me do some reading on trace markers and get back to this.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.
